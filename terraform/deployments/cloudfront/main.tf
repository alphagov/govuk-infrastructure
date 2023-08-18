/**
* ## Project: infra-cloudfront
*
*/

variable "aws_region" {
  type        = string
  description = "AWS region where primary s3 bucket is located"
  default     = "eu-west-1"
}

variable "govuk_environment" {
  type        = string
  description = "AWS Environment"
}

variable "cloudfront_create" {
  description = "Create Cloudfront resources."
  default     = 0
}

variable "cloudfront_enable" {
  description = "Enable Cloudfront distributions."
  default     = false
}

variable "logging_bucket" {
  description = "Logging S3 bucket"
  default     = false
}

variable "origin_www_domain" {
  type        = string
  description = "Domain for the www origin"
  default     = ""
}

variable "origin_www_id" {
  type        = string
  description = "Id for the www origin"
  default     = ""
}

variable "origin_assets_domain" {
  type        = string
  description = "Domain for the assets origin"
  default     = ""
}

variable "origin_assets_id" {
  type        = string
  description = "Id for assets origin"
  default     = ""
}

variable "origin_notify_domain" {
  type        = string
  description = "Domain for the notify origin"
  default     = ""
}

variable "origin_notify_id" {
  type        = string
  description = "Id for the notify origin"
  default     = ""
}

variable "www_web_acl_id" {
  type        = string
  description = "WAF ACL rules id for the WWW cloudfront distribution"
  default     = ""
}

variable "assets_web_acl_id" {
  type        = string
  description = "WAF ACL rules id for the assets cloudfront distribution"
  default     = ""
}

variable "cloudfront_www_distribution_aliases" {
  type        = list(any)
  description = "Extra CNAMEs (alternate domain names), if any, for the WWW CloudFront distribution."
  default     = []
}

variable "cloudfront_www_certificate_domain" {
  type        = string
  description = "The domain of the WWW CloudFront certificate to look up."
  default     = ""
}

variable "www_certificate_arn" {
  type        = string
  description = "The WWW CloudFront certificate"
  default     = ""
}

variable "cloudfront_assets_distribution_aliases" {
  type        = list(any)
  description = "Extra CNAMEs (alternate domain names), if any, for the Assets CloudFront distribution."
  default     = []
}

variable "cloudfront_assets_certificate_domain" {
  type        = string
  description = "The domain of the Assets CloudFront certificate to look up."
  default     = ""
}

variable "assets_certificate_arn" {
  type        = string
  description = "The Assets CloudFront certificate"
  default     = ""
}

variable "notify_cloudfront_domain" {
  type        = string
  description = "The domain of the Notify CloudFront to proxy /alerts requests to."
  default     = ""
}


# Resources
# --------------------------------------------------------------

# Set up the backend & provider for each region
terraform {
  backend "s3" {}
  required_version = "= 1.3.4"
}

provider "aws" {
  region = var.aws_region
}

provider "archive" {
}

#
# CloudFront
#

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
      header_behavior = "none"
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

resource "aws_cloudfront_distribution" "www_distribution" {
  count = var.cloudfront_create

  aliases    = var.cloudfront_www_distribution_aliases
  web_acl_id = var.www_web_acl_id
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
    bucket          = var.logging_bucket
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
    default_ttl            = 86400
    max_ttl                = 31536000
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
    minimum_protocol_version = "TLSv1.1_2016"
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

  tags = {
    govuk_environment = "${var.govuk_environment}"
  }
}

resource "aws_cloudfront_distribution" "assets_distribution" {
  count = var.cloudfront_create
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
    bucket          = var.logging_bucket
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
    default_ttl            = 86400
    max_ttl                = 31536000
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
    minimum_protocol_version = "TLSv1.1_2016"
  }

  tags = {
    govuk_environment = "${var.govuk_environment}"
  }
}
