resource "aws_wafv2_ip_set" "waf_ipv4_set_signon_api" {
  provider           = aws.us_east_1
  name               = "backends_origin_${local.workspace}_cloudfront_access"
  description        = "access to backends origin ${local.workspace} cloudfront"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = concat(var.concourse_cidrs_list, var.office_cidrs_list, local.aws_nat_gateways_cidrs)
}

resource "aws_wafv2_web_acl" "backends_origin_cloudfront_web_acl" {
  provider    = aws.us_east_1
  name        = "backends_origins_${local.workspace}_cloudfront_web_acl"
  description = "Web ACL for backends origin ${local.workspace} cloudfront"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "block_external_access_to_signon_api"
    priority = 11

    action {
      block {}
    }

    statement {
      and_statement {

        # match header host for signon
        statement {
          byte_match_statement {
            field_to_match {
              single_header {
                name = "host"
              }
            }
            positional_constraint = "STARTS_WITH"
            search_string         = "signon."
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }

        # match URL for signon api
        statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }
            positional_constraint = "STARTS_WITH"
            search_string         = "/api/"
            text_transformation {
              priority = 2
              type     = "URL_DECODE"
            }
          }
        }

        # block all IPs not listed below
        statement {
          not_statement {
            statement {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.waf_ipv4_set_signon_api.arn
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "backends-origin-${local.workspace}-cloudfront-signon-api-external-block"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "backends-origin-${local.workspace}-cloudfront"
    sampled_requests_enabled   = true
  }
}


module "backends_origin" {
  source = "../../modules/origin"

  providers           = { aws = aws, random = random }
  name                = "backends"
  vpc_id              = local.vpc_id
  aws_region          = data.aws_region.current.name
  assume_role_arn     = var.assume_role_arn
  public_subnets      = local.public_subnets
  public_zone_id      = aws_route53_zone.workspace_public.zone_id
  external_app_domain = aws_route53_zone.workspace_public.name
  subdomain           = "backends"
  extra_aliases = compact([local.is_default_workspace ? "publisher.${local.workspace}.${var.publishing_service_domain}" : null,
    local.is_default_workspace ? "signon.${local.workspace}.${var.publishing_service_domain}" : null,
    "publisher.${aws_route53_zone.workspace_public.name}",
  "signon.${aws_route53_zone.workspace_public.name}"])
  load_balancer_certificate_arn        = aws_acm_certificate_validation.workspace_public.certificate_arn
  cloudfront_certificate_arn           = aws_acm_certificate_validation.public_north_virginia.certificate_arn
  publishing_service_domain            = var.publishing_service_domain
  workspace                            = local.workspace
  is_default_workspace                 = local.is_default_workspace
  rails_assets_s3_regional_domain_name = aws_s3_bucket.backends_rails_assets.bucket_regional_domain_name
  waf_web_acl_arn                      = aws_wafv2_web_acl.backends_origin_cloudfront_web_acl.arn

  fronted_apps = {
    "publisher" = { security_group_id = module.publisher_web.security_group_id },
    "signon"    = { security_group_id = module.signon.security_group_id },
  }
  additional_tags = local.additional_tags
  environment     = var.govuk_environment
}

## Publisher

resource "aws_lb_target_group" "publisher" {
  name        = "publisher-${local.workspace}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    path = "/healthcheck/ready"
  }

  tags = merge(
    local.additional_tags,
    {
      Name = "publisher-${var.govuk_environment}-${local.workspace}"
    },
  )
}

resource "aws_lb_listener_rule" "publisher" {
  listener_arn = module.backends_origin.origin_alb_listerner_arn
  priority     = 11

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.publisher.arn
  }

  condition {
    http_header {
      http_header_name = "X-Cloudfront-Token"
      values           = [module.backends_origin.origin_alb_x_custom_header_secret]
    }
  }

  condition {
    host_header {
      values = ["publisher.*"]
    }
  }
}

resource "aws_route53_record" "publisher" {
  zone_id = aws_route53_zone.workspace_public.zone_id
  name    = "publisher"
  type    = "CNAME"
  ttl     = 300
  records = [module.backends_origin.fqdn]
}

## Signon

resource "aws_lb_target_group" "signon" {
  name        = "signon-${local.workspace}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    path = "/healthcheck/ready"
  }

  tags = merge(
    local.additional_tags,
    {
      Name = "signon-${var.govuk_environment}-${local.workspace}"
    },
  )


}

resource "aws_lb_listener_rule" "signon" {
  listener_arn = module.backends_origin.origin_alb_listerner_arn
  priority     = 12

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.signon.arn
  }

  condition {
    http_header {
      http_header_name = "X-Cloudfront-Token"
      values           = [module.backends_origin.origin_alb_x_custom_header_secret]
    }
  }

  condition {
    host_header {
      values = ["signon.*"]
    }
  }
}

resource "aws_route53_record" "signon" {
  zone_id = aws_route53_zone.workspace_public.zone_id
  name    = "signon"
  type    = "CNAME"
  ttl     = 300
  records = [module.backends_origin.fqdn]
}
