resource "aws_wafv2_ip_set" "origin_cloudfront_ipv4_access" {
  provider           = aws.us_east_1
  name               = "${local.live_or_draft_prefix}_origin_${var.workspace}_cloudfront_access"
  description        = "access to ${local.live_or_draft_prefix} origin ${var.workspace} cloudfront"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.allowlist_cidrs
}

resource "aws_wafv2_web_acl" "origin_cloudfront_web_acl" {
  provider    = aws.us_east_1
  name        = "${local.live_or_draft_prefix}_origin_${var.workspace}_cloudfront_web_acl"
  description = "Web ACL for ${local.live_or_draft_prefix}-origin ${var.workspace} cloudfront"
  scope       = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name     = "allow-requests-from-selected-IPv4-addresses"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.origin_cloudfront_ipv4_access.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.live_or_draft_prefix}-origin-${var.workspace}-cloudfront-ip-allow"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.live_or_draft_prefix}-origin-${var.workspace}-cloudfront"
    sampled_requests_enabled   = true
  }
}
