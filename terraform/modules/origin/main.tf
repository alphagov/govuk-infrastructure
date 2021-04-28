locals {
  origin_alb_id = "${var.name}_origin_alb"
  origin_s3_id  = "origin_s3"
}

resource "aws_cloudfront_origin_access_identity" "cloudfront_s3_access" {
  comment = "${var.name}-origin ${var.workspace} cloudfront accessing the Rails assets s3 bucket"
}

resource "random_password" "origin_alb_x_custom_header_secret" {
  length  = 32
  special = false
}

resource "aws_cloudfront_distribution" "origin" {
  origin {
    domain_name = aws_lb.origin.dns_name
    origin_id   = local.origin_alb_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    #TODO: frequent rototation for additional security: https://trello.com/c/gOCvdwRd/255-rotate-x-cloudfront-token
    custom_header {
      name  = "X-Cloudfront-Token"
      value = random_password.origin_alb_x_custom_header_secret.result
    }

  }

  origin {
    domain_name = var.rails_assets_s3_regional_domain_name
    origin_id   = local.origin_s3_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_s3_access.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = false
  comment         = "${var.name}-origin ${var.workspace} CDN in front of origin ALB and s3 rails assets bucket"
  web_acl_id      = var.waf_web_acl_arn

  aliases = concat(var.extra_aliases, ["${var.subdomain}.${var.external_app_domain}"])

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_alb_id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }

      headers = ["*"]
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "/assets/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.origin_s3_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.cloudfront_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }
}

resource "aws_route53_record" "origin_cloudfront" {
  zone_id = var.public_zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.origin.domain_name
    zone_id                = aws_cloudfront_distribution.origin.hosted_zone_id
    evaluate_target_health = false
  }
}
