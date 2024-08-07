resource "aws_cloudfront_cache_policy" "no-cookies" {
  name        = "no-cookies"
  default_ttl = 300
  max_ttl     = 31536000
  min_ttl     = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Host"]
      }
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "all-viewer-headers" {
  name = "all-headers-cookies"
  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "allViewer"
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}


resource "aws_cloudfront_distribution" "chat_distribution" {
  count = var.cloudfront_create ? 1 : 0

  aliases    = var.cloudfront_chat_distribution_aliases
  web_acl_id = aws_wafv2_web_acl.cdn_poc_govuk.arn
  origin {
    domain_name = var.origin_www_domain
    origin_id   = var.origin_www_id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = var.origin_notify_domain
    origin_id   = var.origin_notify_id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled         = var.cloudfront_enable
  is_ipv6_enabled = true
  comment         = "WWW"

  logging_config {
    include_cookies = false
    bucket          = "govuk-${var.govuk_environment}-aws-logging.s3.amazonaws.com"
    prefix          = "cloudfront/"
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = var.origin_www_id
    compress                 = "true"
    cache_policy_id          = aws_cloudfront_cache_policy.no-cookies.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.all-viewer-headers.id

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
  }

  ordered_cache_behavior {
    path_pattern           = "/alerts"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.origin_notify_id
    compress               = "false"
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern           = "/alerts/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.origin_notify_id
    compress               = "false"
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.www_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  custom_error_response {
    error_code            = 403
    response_code         = 503
    response_page_path    = "/error/503.html"
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 404
    response_code         = 503
    response_page_path    = "/error/503.html"
    error_caching_min_ttl = 300
  }
}

resource "aws_cloudfront_distribution" "assets_distribution" {
  count      = var.cloudfront_create ? 1 : 0
  web_acl_id = aws_wafv2_web_acl.cdn_poc_govuk.arn
  origin {
    domain_name = var.origin_assets_domain
    origin_id   = var.origin_assets_id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled         = var.cloudfront_enable
  is_ipv6_enabled = true
  comment         = "Assets"

  logging_config {
    include_cookies = false
    bucket          = "govuk-${var.govuk_environment}-aws-logging.s3.amazonaws.com"
    prefix          = "cloudfront/"
  }

  aliases = var.cloudfront_assets_distribution_aliases

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.origin_assets_id
    cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6"


    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
  }

  price_class = "PriceClass_All"


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.assets_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
