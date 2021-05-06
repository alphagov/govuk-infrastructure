resource "aws_wafv2_ip_set" "all_frontends_origins_cloudfront_ipv4_access" {
  provider           = aws.us_east_1
  name               = "all_frontends_origins_${local.workspace}_cloudfront_access"
  description        = "access to all frontends origins ${local.workspace} cloudfront"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = local.is_default_workspace ? concat(var.office_cidrs_list, data.fastly_ip_ranges.fastly.cidr_blocks, local.aws_nat_gateways_cidrs) : concat(var.office_cidrs_list, local.aws_nat_gateways_cidrs)
}

resource "aws_wafv2_web_acl" "all_frontends_origins_cloudfront_web_acl" {
  provider    = aws.us_east_1
  name        = "all_frontends_origins_${local.workspace}_cloudfront_web_acl"
  description = "Web ACL for all frontends origins ${local.workspace} cloudfront"
  scope       = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name     = "allow-requests-from-selected-IPv4-addresses"
    priority = 11

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.all_frontends_origins_cloudfront_ipv4_access.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "all-frontends-origins-${local.workspace}-cloudfront-ip-allow"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "all-frontends-origins-${local.workspace}-cloudfront"
    sampled_requests_enabled   = true
  }
}


module "www_frontends_origin" {
  source = "../../modules/origin"

  providers                            = { aws = aws, random = random }
  name                                 = "www-frontends"
  vpc_id                               = local.vpc_id
  aws_region                           = data.aws_region.current.name
  assume_role_arn                      = var.assume_role_arn
  public_subnets                       = local.public_subnets
  public_zone_id                       = aws_route53_zone.workspace_public.zone_id
  external_app_domain                  = aws_route53_zone.workspace_public.name
  subdomain                            = "www-origin"
  extra_aliases                        = local.is_default_workspace ? ["www.${local.workspace}.${var.publishing_service_domain}"] : []
  load_balancer_certificate_arn        = aws_acm_certificate_validation.workspace_public.certificate_arn
  cloudfront_certificate_arn           = aws_acm_certificate_validation.public_north_virginia.certificate_arn
  publishing_service_domain            = var.publishing_service_domain
  workspace                            = local.workspace
  is_default_workspace                 = local.is_default_workspace
  rails_assets_s3_regional_domain_name = aws_s3_bucket.frontends_rails_assets.bucket_regional_domain_name
  waf_web_acl_arn                      = aws_wafv2_web_acl.all_frontends_origins_cloudfront_web_acl.arn

  fronted_apps = {
    "router" = { security_group_id = module.router.security_group_id },
  }
  additional_tags = local.additional_tags
  environment     = var.govuk_environment
}

resource "aws_lb_target_group" "router" {
  name        = "router-${local.workspace}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }

  tags = merge(
    local.additional_tags,
    {
      Name = "router-${var.govuk_environment}-${local.workspace}"
    },
  )
}

resource "aws_lb_listener_rule" "router" {
  listener_arn = module.www_frontends_origin.origin_alb_listerner_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.router.arn
  }

  condition {
    http_header {
      http_header_name = "X-Cloudfront-Token"
      values           = [module.www_frontends_origin.origin_alb_x_custom_header_secret]
    }
  }
}

module "draft_frontends_origin" {
  source = "../../modules/origin"

  providers                            = { aws = aws, aws.us_east_1 = aws.us_east_1, random = random }
  name                                 = "draft-frontends"
  vpc_id                               = local.vpc_id
  aws_region                           = data.aws_region.current.name
  assume_role_arn                      = var.assume_role_arn
  public_subnets                       = local.public_subnets
  public_zone_id                       = aws_route53_zone.workspace_public.zone_id
  external_app_domain                  = aws_route53_zone.workspace_public.name
  subdomain                            = "draft-origin"
  load_balancer_certificate_arn        = aws_acm_certificate_validation.workspace_public.certificate_arn
  cloudfront_certificate_arn           = aws_acm_certificate_validation.public_north_virginia.certificate_arn
  publishing_service_domain            = var.publishing_service_domain
  workspace                            = local.workspace
  is_default_workspace                 = local.is_default_workspace
  rails_assets_s3_regional_domain_name = aws_s3_bucket.frontends_rails_assets.bucket_regional_domain_name
  waf_web_acl_arn                      = aws_wafv2_web_acl.all_frontends_origins_cloudfront_web_acl.arn

  fronted_apps = {
    "authenticating-proxy" = { security_group_id = module.authenticating_proxy.security_group_id },
  }
  additional_tags = local.additional_tags
  environment     = var.govuk_environment
}

resource "aws_lb_target_group" "authenticating_proxy" {
  name        = "authenticating-proxy-${local.workspace}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    path = "/healthcheck/live"
  }

  tags = merge(
    local.additional_tags,
    {
      Name = "draft-router-${var.govuk_environment}-${local.workspace}"
    },
  )
}

resource "aws_lb_listener_rule" "authenticating_proxy" {
  listener_arn = module.draft_frontends_origin.origin_alb_listerner_arn
  priority     = 11

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.authenticating_proxy.arn
  }

  condition {
    http_header {
      http_header_name = "X-Cloudfront-Token"
      values           = [module.draft_frontends_origin.origin_alb_x_custom_header_secret]
    }
  }
}
