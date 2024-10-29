resource "aws_wafv2_web_acl" "chat_waf_rules" {
  name        = "govuk_chat_web_acl"
  description = "WAF Ruleset for GOVUK Chat Service"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Amazon core rule set (CRS) managed rule group
  # Contains rules that are generally applicable to web applications. This
  # provides protection against exploitation of a wide range of vulnerabilities,
  # including those described in OWASP publications.
  rule {
    name     = "aws-managed-rules-common-rule-set"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Amazon IP reputation list managed rule group
  # The Amazon IP reputation list rule group contains rules that are based on
  # Amazon internal threat intelligence. This is useful for blocking IP addresses
  # typically associated with bots or other threats. Blocking these IP addresses
  # can help mitigate bots and reduce the risk of a malicious actor discovering
  # a vulnerable application.
  rule {
    name     = "aws-managed-rules-ip-reputation-list"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  # Anonymous IP list managed rule group
  # The Anonymous IP list rule group contains rules to block requests from services
  # that permit the obfuscation of viewer identity. These include requests from
  # VPNs, proxies, Tor nodes, and web hosting providers. This rule group is useful
  # for filtering out viewers that might be trying to hide their identity from your
  # application. Blocking the IP addresses of these services can help mitigate bots
  # and evasion of geographic restrictions.
  rule {
    name     = "aws-managed-rules-anonymous-ip-list"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAnonymousIpList"
      sampled_requests_enabled   = true
    }
  }

  # this rule matches any request that contains the header X-Always-Block: true
  # we use it as a simple sense check / acceptance test from smokey to ensure that
  # the waf is enabled and processing requests
  rule {
    name     = "x-always-block-web-acl-rule"
    priority = 40

    override_action {
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = data.aws_wafv2_rule_group.x_always_block.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "x-always-block-rule-group"
      sampled_requests_enabled   = true
    }
  }

  # this rule matches any request that contains NAT gateway IPs in the True-Client-IP
  # header and allows it.
  rule {
    name     = "allow-govuk-infra"
    priority = 50

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = data.aws_wafv2_ip_set.govuk_requesting_ips.arn

        ip_set_forwarded_ip_config {
          fallback_behavior = "NO_MATCH"
          header_name       = "true-client-ip"
          position          = "FIRST"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "govuk-infra-cache-requests"
      sampled_requests_enabled   = true
    }
  }

  # allow Fastly healthchecks to pass unhindered
  rule {
    name     = "allow-fastly-healthchecks"
    priority = 60

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "rate-limit-token"
          }
        }

        positional_constraint = "EXACTLY"
        search_string         = data.aws_secretsmanager_secret_version.fastly_token.secret_string

        text_transformation {
          priority = 1
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "fastly-healthcheck-requests"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "ratelimit-exemptions"
    priority = 70

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = data.aws_wafv2_ip_set.high_request_rate.arn

        ip_set_forwarded_ip_config {
          fallback_behavior = "NO_MATCH"
          header_name       = "true-client-ip"
          position          = "FIRST"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ratelimit-exempt-requests"
      sampled_requests_enabled   = true
    }
  }

  # This rule is intended for monitoring only
  # set a base rate limit per IP looking back over the last 5 minutes
  # this is checked every 30s
  rule {
    name     = "cache-public-base-rate-warning"
    priority = 80

    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = var.waf_cache_rate_warning
        aggregate_key_type = "FORWARDED_IP"

        forwarded_ip_config {
          # We expect all requests to have this header set. As we're counting,
          #it's a good chance to verify that by matching any that don't
          fallback_behavior = "MATCH"
          header_name       = "true-client-ip"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "cache-public-base-rate-warning"
      sampled_requests_enabled   = true
    }
  }

  # set a base rate limit per IP looking back over the last 5 minutes
  # this is checked every 30s
  rule {
    name     = "cache-public-base-rate-limit"
    priority = 90

    action {
      block {
        custom_response {
          response_code = 429

          response_header {
            name  = "Retry-After"
            value = 30
          }

          response_header {
            name  = "Cache-Control"
            value = "max-age=0, private"
          }

          custom_response_body_key = "cache-public-rule-429"
        }
      }
    }

    statement {
      rate_based_statement {
        limit              = var.waf_cache_rate_limit
        aggregate_key_type = "FORWARDED_IP"

        forwarded_ip_config {
          # We expect all requests to have this header set. As we're counting,
          #it's a good chance to verify that by matching any that don't
          fallback_behavior = "MATCH"
          header_name       = "true-client-ip"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "cache-public-base-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  custom_response_body {
    key     = "cache-public-rule-429"
    content = <<HTML
      <!DOCTYPE html>
      <html>
        <head>
          <title>Welcome to GOV.UK</title>
          <style>
            body { font-family: Arial, sans-serif; margin: 0; }
            header { background: black; }
            h1 { color: white; font-size: 29px; margin: 0 auto; padding: 10px; max-width: 990px; }
            p { color: black; margin: 30px auto; max-width: 990px; }
          </style>
        </head>
        <body>
          <header><h1>GOV.UK</h1></header>
          <p>Sorry, there have been too many attempts to access this page.</p>
          <p>Try again in a few minutes.</p>
        </body>
      </html>
      HTML

    content_type = "TEXT_HTML"
  }

  rule {
    name     = "block-autodiscover"
    priority = 100
    action {
      block {
        custom_response {
          response_code = "404"
        }
      }
    }

    statement {
      byte_match_statement {
        field_to_match {
          uri_path {}
        }
        positional_constraint = "EXACTLY"
        search_string         = "/autodiscover/autodiscover.xml"
        text_transformation {
          type     = "LOWERCASE"
          priority = 1
        }
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "block-autodiscover"
    }
  }

  # Silently ignore requests to the contact form with blank user agents.
  # This was the signature of a spam attack on 2020-11-18; see doc:
  # https://docs.google.com/document/d/12DzQsDeu7zUcICy9zVporjprX4qZFIrpOOWtYYRx-nk/edit#
  rule {
    name     = "drop-bad-contact-form-requests"
    priority = 110

    action {
      block {
        custom_response {
          response_code = 302
          response_header {
            name  = "Location"
            value = "/contact/govuk/thankyou"
          }
        }
      }
    }

    statement {
      and_statement {
        statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }
            positional_constraint = "EXACTLY"
            search_string         = "/contact/govuk"
            text_transformation {
              type     = "LOWERCASE"
              priority = 0
            }
          }
        }
        statement {
          byte_match_statement {
            field_to_match {
              method {}
            }
            positional_constraint = "EXACTLY"
            search_string         = "POST"
            text_transformation {
              type     = "NONE"
              priority = 0
            }
          }
        }
        statement {
          not_statement {
            statement {
              size_constraint_statement {
                comparison_operator = "GE"
                size                = 1
                field_to_match {
                  single_header {
                    name = "user-agent"
                  }
                }
                text_transformation {
                  type     = "COMPRESS_WHITE_SPACE"
                  priority = 0
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "drop-bad-contact-form-requests"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "GOVUK-Chat-Web-ACLs"
    sampled_requests_enabled   = true
  }
}

resource "aws_cloudwatch_log_group" "govuk_chat_waf" {
  # the name must start with aws-waf-logs
  # https://docs.aws.amazon.com/waf/latest/developerguide/logging-cw-logs.html#logging-cw-logs-naming
  name              = "aws-waf-logs-govuk-chat-${var.govuk_environment}"
  retention_in_days = 30
}

resource "aws_wafv2_web_acl_logging_configuration" "govuk_chat_waf" {
  log_destination_configs = [aws_cloudwatch_log_group.govuk_chat_waf.arn]
  resource_arn            = aws_wafv2_web_acl.chat_waf_rules.arn

  logging_filter {
    default_behavior = "DROP"

    filter {
      behavior = "KEEP"

      condition {
        action_condition {
          action = "COUNT"
        }
      }

      condition {
        action_condition {
          action = "BLOCK"
        }
      }

      requirement = "MEETS_ANY"
    }
  }
}
