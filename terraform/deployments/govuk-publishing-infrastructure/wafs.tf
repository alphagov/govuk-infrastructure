# this rule matches any request that contains the header X-Always-Block: true
# we use it as a simple sanity check / acceptance test from smokey to ensure that
# the waf is enabled and processing requests
#

module "infrastructure-sensitive_wafs" {
  source  = "app.terraform.io/govuk/infrastructure-sensitive/govuk//modules/wafs"
  version = "0.0.9"

  cache_public_base_rate_limit   = var.cache_public_base_rate_limit
  cache_public_base_rate_warning = var.cache_public_base_rate_warning
  govuk_requesting_ips_arn       = aws_wafv2_ip_set.govuk_requesting_ips.arn
  high_request_rate_ips_arn      = aws_wafv2_ip_set.high_request_rate.arn
  x_always_block_arn             = aws_wafv2_rule_group.x_always_block.arn
}


moved {
  from = aws_wafv2_web_acl.cache_public
  to   = module.infrastructure-sensitive_wafs.aws_wafv2_web_acl.cache_public
}

resource "aws_wafv2_web_acl" "default" {
  name  = "x-always-block_web_acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  lifecycle {
    ignore_changes = [
      rule
    ]
  }

  rule {
    name     = "x-always-block_web_acl_rule"
    priority = 1

    override_action {
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.x_always_block.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "x-always-block-rule-group"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "x-always-block-web-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_regex_pattern_set" "x_always_block" {
  name        = "x-always-block_pattern"
  description = "Matches the text we expect in the header"
  scope       = "REGIONAL"

  regular_expression {
    regex_string = "true"
  }
}

resource "aws_wafv2_rule_group" "x_always_block" {
  name  = "x-always-block_rule_group"
  scope = "REGIONAL"

  # regex_pattern_set = 25
  # leaving a bit of head room as this number is immutable
  capacity = 50

  rule {
    name     = "x-always-block_rule"
    priority = 1

    action {
      block {}
    }

    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.x_always_block.arn

        field_to_match {
          single_header {
            name = "x-always-block"
          }
        }

        text_transformation {
          priority = 1
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "x-always-block-rule"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "x-always-block-rule-group"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_ip_set" "govuk_requesting_ips" {
  name               = "govuk_requesting_ips"
  description        = "The IP addresses used by our infra to make requests that hit the cache LB."
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  # addresses          = formatlist("%s/32", data.tfe_outputs.cluster_infrastructure.nonsensitive_values.public_nat_gateway_ips)

  lifecycle {
    ignore_changes = [
      addresses
    ]
  }

}

resource "aws_wafv2_ip_set" "high_request_rate" {
  name               = "high_request_rate"
  description        = "Source addresses from which we allow a higher ratelimit."
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  # addresses          = var.allow_high_request_rate_from_cidrs

  lifecycle {
    ignore_changes = [
      addresses
    ]
  }
}

resource "aws_wafv2_web_acl" "backend_public" {
  name  = "backend_public_web_acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  lifecycle {
    ignore_changes = [
      rule
    ]
  }

  # this rule matches any request that contains the header X-Always-Block: true
  # we use it as a simple sanity check / acceptance test from smokey to ensure that
  # the waf is enabled and processing requests
  rule {
    name     = "x-always-block_web_acl_rule"
    priority = 10

    override_action {
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.x_always_block.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "x-always-block-rule-group"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "rate-limit-exemptions"
    priority = 20

    action {
      allow {}
    }

    statement {
      or_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.govuk_requesting_ips.arn
          }
        }
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.high_request_rate.arn
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "govuk-infra-backend-requests"
      sampled_requests_enabled   = true
    }
  }

  # This rule is intended for monitoring only
  # set a base rate limit per IP looking back over the last 5 minutes
  # this is checked every 30s
  rule {
    name     = "backend-public-base-rate-warning"
    priority = 30

    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = var.backend_public_base_rate_warning
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "backend-public-base-rate-warning"
      sampled_requests_enabled   = true
    }
  }

  # set a base rate limit per IP looking back over the last 5 minutes
  # this is checked every 30s
  rule {
    name     = "backend-public-base-rate-limit"
    priority = 40

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

          custom_response_body_key = "backend-public-rule-429"
        }
      }
    }

    statement {
      rate_based_statement {
        limit              = var.backend_public_base_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "backend-public-base-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  dynamic "rule" {
    for_each = var.backend_public_ja3_denylist
    iterator = signature

    content {
      name = "deny-ja3-${signature.value}"

      # All rules require a unique priority, and the size of the JA3 denylist is potentially unbounded,
      # so we add these rules to the end of the list to avoid collisions.
      priority = 50 + signature.key

      action {
        block {}
      }

      statement {
        byte_match_statement {
          positional_constraint = "EXACTLY"
          search_string         = signature.value

          field_to_match {
            ja3_fingerprint {
              fallback_behavior = "NO_MATCH"
            }
          }

          text_transformation {
            type     = "NONE"
            priority = 0
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "deny-ja3-${signature.value}"
        sampled_requests_enabled   = true
      }
    }
  }

  custom_response_body {
    key     = "backend-public-rule-429"
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

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "backend-public-web-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_cloudwatch_log_group" "public_backend_waf" {
  # the name must start with aws-waf-logs
  # https://docs.aws.amazon.com/waf/latest/developerguide/logging-cw-logs.html#logging-cw-logs-naming
  name              = "aws-waf-logs-backend-public-${var.govuk_environment}"
  retention_in_days = var.waf_log_retention_days

}

resource "aws_wafv2_web_acl_logging_configuration" "public_backend_waf" {
  log_destination_configs = [aws_cloudwatch_log_group.public_backend_waf.arn]
  resource_arn            = aws_wafv2_web_acl.backend_public.arn
}

resource "aws_wafv2_web_acl" "bouncer_public" {
  name  = "bouncer_public_web_acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  lifecycle {
    ignore_changes = [
      rule
    ]
  }

  # this rule matches any request that contains the header X-Always-Block: true
  # we use it as a simple sanity check / acceptance test from smokey to ensure that
  # the waf is enabled and processing requests
  rule {
    name     = "x-always-block_web_acl_rule"
    priority = 1

    override_action {
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.x_always_block.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "x-always-block-rule-group"
      sampled_requests_enabled   = true
    }
  }

  # This rule is intended for monitoring only
  # set a base rate limit per IP looking back over the last 5 minutes
  # this is checked every 30s
  rule {
    name     = "bouncer-public-base-rate-warning"
    priority = 2

    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = var.bouncer_public_base_rate_warning
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
      metric_name                = "bouncer-public-base-rate-warning"
      sampled_requests_enabled   = true
    }
  }

  # set a base rate limit per IP looking back over the last 5 minutes
  # this is checked every 30s
  rule {
    name     = "bouncer-public-base-rate-limit"
    priority = 3

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

          custom_response_body_key = "bouncer-public-rule-429"
        }
      }
    }

    statement {
      rate_based_statement {
        limit              = var.bouncer_public_base_rate_limit
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
      metric_name                = "bouncer-public-base-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  custom_response_body {
    key     = "bouncer-public-rule-429"
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

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "bouncer-public-web-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_cloudwatch_log_group" "public_bouncer_waf" {
  # the name must start with aws-waf-logs
  # https://docs.aws.amazon.com/waf/latest/developerguide/logging-cw-logs.html#logging-cw-logs-naming
  name              = "aws-waf-logs-bouncer-public-${var.govuk_environment}"
  retention_in_days = var.waf_log_retention_days
}

resource "aws_wafv2_web_acl_logging_configuration" "public_bouncer_waf" {
  log_destination_configs = [aws_cloudwatch_log_group.public_bouncer_waf.arn]
  resource_arn            = aws_wafv2_web_acl.bouncer_public.arn

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

resource "aws_cloudwatch_log_group" "public_cache_waf" {
  # the name must start with aws-waf-logs
  # https://docs.aws.amazon.com/waf/latest/developerguide/logging-cw-logs.html#logging-cw-logs-naming
  name              = "aws-waf-logs-cache-public-${var.govuk_environment}"
  retention_in_days = var.waf_log_retention_days
}

resource "aws_wafv2_web_acl_logging_configuration" "public_cache_waf" {
  log_destination_configs = [aws_cloudwatch_log_group.public_cache_waf.arn]
  resource_arn            = module.infrastructure-sensitive_wafs.public_cache_waf_arn

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
