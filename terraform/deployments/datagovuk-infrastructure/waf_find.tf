# AWS WAF for Find application rate limiting
# This is to implement and add WAF to nginx ingress to address 503 errors

# ===========================================================
# Data sources to find Find ALB using Kubernetes tags
# ===========================================================

data "aws_lb" "find" {
  tags = {
    "elbv2.k8s.aws/cluster" = "govuk"
    "ingress.k8s.aws/stack" = "datagovuk/find"
  }
}

# ===========================================================
# WAF Web ACL and Rules for Find application
# ===========================================================

# Main WAF Web ACL for Find application
resource "aws_wafv2_web_acl" "find" {
  name  = "find-${var.govuk_environment}-rate-limiting"
  scope = "REGIONAL"
  default_action {
    allow {}
  }
  # Rule 1: Rate limit warning (monitoring only)
  # This rule counts requests approaching the limit but doesn't block
  # Useful for monitoring and adjusting limits before blocking occurs
  rule {
    name     = "find-rate-limit-warning"
    priority = 1
    action {
      count {}
    }
    statement {
      rate_based_statement {
        limit              = var.find_rate_limit_warning_per_5min
        aggregate_key_type = "FORWARDED_IP"
        # Fastly CDN passes real client IP in true-client-ip header
        # This ensures we rate limit per actual client IP, not Fastly's IPs
        forwarded_ip_config {
          fallback_behavior = "MATCH"
          header_name       = "true-client-ip"
        }
        # Only apply rate limiting to Find hostname requests
        scope_down_statement {
          byte_match_statement {
            search_string = "find"
            field_to_match {
              single_header {
                name = "host"
              }
            }
            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
            positional_constraint = "CONTAINS"
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "find-rate-limit-warning"
      sampled_requests_enabled   = true
    }
  }
  # Rule 2: Rate limit blocking
  # This rule actually blocks requests that exceed the limit
  rule {
    name     = "find-rate-limit-block"
    priority = 2
    action {
      block {
        custom_response {
          response_code            = 429
          custom_response_body_key = "find-rate-limit-429"
          # This is to inform clients to retry after 30 seconds
          response_header {
            name  = "Retry-After"
            value = "30"
          }
          # Prevent caching of error response
          response_header {
            name  = "Cache-Control"
            value = "max-age=0, private"
          }
        }
      }
    }
    statement {
      rate_based_statement {
        limit              = var.find_rate_limit_per_5min
        aggregate_key_type = "FORWARDED_IP"
        forwarded_ip_config {
          fallback_behavior = "MATCH"
          header_name       = "true-client-ip"
        }
        scope_down_statement {
          byte_match_statement {
            search_string = "find"
            field_to_match {
              single_header {
                name = "host"
              }
            }
            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
            positional_constraint = "CONTAINS"
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "find-rate-limit-block"
      sampled_requests_enabled   = true
    }
  }
  # Custom 429 "Too Many Requests" response page
  # Styled to match GOV.UK design system
  custom_response_body {
    key          = "find-rate-limit-429"
    content_type = "TEXT_HTML"
    content      = <<HTML
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Too many requests - GOV.UK</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
      body {
        font-family: "GDS Transport", Arial, sans-serif;
        margin: 0;
        padding: 40px 20px;
        background: #F3F2F1;
        color: #0B0C0C;
      }
      .container {
        max-width: 600px;
        margin: 0 auto;
        background: white;
        padding: 40px;
        border: 1px solid #B1B4B6;
      }
      h1 {
        font-size: 32px;
        font-weight: 700;
        margin: 0 0 20px 0;
      }
      p {
        line-height: 1.6;
        margin: 20px 0;
        font-size: 19px;
      }
      .logo {
        margin-bottom: 30px;
        font-weight: 700;
        font-size: 24px;
      }
      a {
        color: #1D70B8;
        text-decoration: underline;
      }
      a:visited {
        color: #4C2C92;
      }
      a:hover {
        text-decoration: none;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="logo">GOV.UK</div>
      <h1>Sorry, there have been too many requests</h1>
      <p>You have made too many requests to Find open data in a short period of time.</p>
      <p>Please wait a few minutes and try again.</p>
      <p>If you need to access large amounts of data, please consider using our <a href="https://www.data.gov.uk/api">API</a> or downloading our <a href="https://www.data.gov.uk/harvest">bulk datasets</a>.</p>
    </div>
  </body>
</html>
HTML
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "find-web-acl"
    sampled_requests_enabled   = true
  }
  tags = {
    Name        = "find-${var.govuk_environment}-waf"
    Application = "Find"
    Purpose     = "RateLimiting"
  }
}

# ===========================================================
# WAF Association and CloudWatch Logging Configuration
# ===========================================================

# Associate WAF with Find ALB and this attaches the WAF rules to the ALB
resource "aws_wafv2_web_acl_association" "find_alb" {
  resource_arn = data.aws_lb.find.arn
  web_acl_arn  = aws_wafv2_web_acl.find.arn
}

# CloudWatch Log Group for WAF logs
# Stores logs of blocked and counted requests
resource "aws_cloudwatch_log_group" "find_waf" {
  name              = "aws-waf-logs-find-${var.govuk_environment}"
  retention_in_days = var.waf_log_retention_days
  tags = {
    Name        = "find-waf-logs"
    Application = "Find"
    Purpose     = "WAFLogging"
  }
}

# WAF Logging Config which sends WAF events to CloudWatch Logs
resource "aws_wafv2_web_acl_logging_configuration" "find_waf" {
  resource_arn            = aws_wafv2_web_acl.find.arn
  log_destination_configs = [aws_cloudwatch_log_group.find_waf.arn]
  # Only log blocked and counted requests (not all allowed requests)
  logging_filter {
    default_behavior = "DROP"
    # Keep COUNT actions (warning threshold hits)
    filter {
      behavior    = "KEEP"
      requirement = "MEETS_ANY"
      condition {
        action_condition {
          action = "COUNT"
        }
      }
    }
    # Keep BLOCK actions (actual rate limit blocks)
    filter {
      behavior    = "KEEP"
      requirement = "MEETS_ANY"
      condition {
        action_condition {
          action = "BLOCK"
        }
      }
    }
  }
  # Redact sensitive headers from logs for security
  redacted_fields {
    single_header {
      name = "authorization"
    }
  }
  redacted_fields {
    single_header {
      name = "cookie"
    }
  }
}
