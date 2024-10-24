locals {
  managed_cache_policy_caching_optimized                         = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  managed_cache_policy_caching_disabled                          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  managed_request_policy_cors_s3_origin                          = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
  managed_cache_request_policy_all_viewer_and_cloudfront_headers = "33f36d7e-f396-46d9-90e0-52428a34d9dc"
}

resource "aws_cloudfront_origin_access_control" "govuk-chat" {
  name                              = "govuk-chat"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "chat_distribution" {
  count = var.cloudfront_create ? 1 : 0

  aliases = var.cloudfront_chat_distribution_aliases
  origin {
    domain_name = var.origin_chat_domain
    origin_id   = var.origin_chat_id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name              = aws_s3_bucket.origin_service_disabled.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.govuk-chat.id
    origin_id                = aws_s3_bucket.origin_service_disabled.id
  }

  enabled         = var.cloudfront_enable
  is_ipv6_enabled = true
  comment         = "Chat"

  logging_config {
    include_cookies = false
    bucket          = "govuk-${var.govuk_environment}-aws-logging.s3.amazonaws.com"
    prefix          = "cloudfront/"
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = var.service_disabled ? aws_s3_bucket.origin_service_disabled.id : var.origin_chat_id
    compress                 = "true"
    cache_policy_id          = var.service_disabled ? local.managed_cache_policy_caching_optimized : local.managed_cache_policy_caching_disabled
    origin_request_policy_id = var.service_disabled ? local.managed_request_policy_cors_s3_origin : local.managed_cache_request_policy_all_viewer_and_cloudfront_headers

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    dynamic "function_association" {
      for_each = var.service_disabled ? [1] : []
      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.add_index.arn
      }
    }
  }
  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.chat_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_s3_bucket" "origin_service_disabled" {
  bucket = "govuk-chat-${var.govuk_environment}"
}

resource "aws_s3_bucket_policy" "origin_service_disabled" {
  bucket = aws_s3_bucket.origin_service_disabled.id
  policy = data.aws_iam_policy_document.origin_service_disabled.json
}

data "aws_iam_policy_document" "origin_service_disabled" {
  statement {
    sid = "AllowCloudFrontServicePrincipal"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]
    resources = [
      aws_s3_bucket.origin_service_disabled.arn,
      "${aws_s3_bucket.origin_service_disabled.arn}/*",
    ]
    condition {
      test     = "StringEquals"
      values   = ["${aws_cloudfront_distribution.chat_distribution[0].id}"]
      variable = "AWS:SourceArn"
    }
  }
}

resource "aws_cloudfront_function" "add_index" {
  name    = "add_index"
  runtime = "cloudfront-js-2.0"
  code    = file("${path.module}/add_index.js")
}

resource "aws_shield_protection" "chat_shield_protection" {
  name         = "Chat"
  resource_arn = aws_cloudfront_distribution.chat_distribution[0].arn
}
