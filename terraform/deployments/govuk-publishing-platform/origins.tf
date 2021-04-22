resource "aws_acm_certificate" "public_north_virginia" {
  provider    = aws.us_east_1
  domain_name = "*.${local.workspace_external_domain}"

  subject_alternative_names = local.is_default_workspace ? ["*.${local.workspace}.${var.publishing_service_domain}"] : null

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "public_north_virginia" {
  provider = aws.us_east_1
  for_each = {
    for dvo in aws_acm_certificate.public_north_virginia.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.workspace_public.zone_id
}

resource "aws_acm_certificate_validation" "public_north_virginia" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.public_north_virginia.arn
  validation_record_fqdns = [for record in aws_route53_record.public_north_virginia : record.name]
}


module "www_origin" {
  source = "../../modules/origin"

  vpc_id                               = local.vpc_id
  aws_region                           = data.aws_region.current.name
  assume_role_arn                      = var.assume_role_arn
  public_subnets                       = local.public_subnets
  public_zone_id                       = aws_route53_zone.workspace_public.zone_id
  external_app_domain                  = aws_route53_zone.workspace_public.name
  load_balancer_certificate_arn        = aws_acm_certificate_validation.workspace_public.certificate_arn
  cloudfront_certificate_arn           = aws_acm_certificate_validation.public_north_virginia.certificate_arn
  publishing_service_domain            = var.publishing_service_domain
  workspace                            = local.workspace
  is_default_workspace                 = local.is_default_workspace
  external_cidrs_list                  = concat(var.office_cidrs_list, data.fastly_ip_ranges.fastly.cidr_blocks)
  rails_assets_s3_regional_domain_name = aws_s3_bucket.rails_assets.bucket_regional_domain_name

  apps_security_config_list = {
    "router" = { security_group_id = module.router.security_group_id, target_port = 80 },
  }
}

module "draft_origin" {
  source = "../../modules/origin"

  vpc_id                               = local.vpc_id
  aws_region                           = data.aws_region.current.name
  assume_role_arn                      = var.assume_role_arn
  public_subnets                       = local.public_subnets
  public_zone_id                       = aws_route53_zone.workspace_public.zone_id
  external_app_domain                  = aws_route53_zone.workspace_public.name
  load_balancer_certificate_arn        = aws_acm_certificate_validation.workspace_public.certificate_arn
  cloudfront_certificate_arn           = aws_acm_certificate_validation.public_north_virginia.certificate_arn
  publishing_service_domain            = var.publishing_service_domain
  workspace                            = local.workspace
  is_default_workspace                 = local.is_default_workspace
  external_cidrs_list                  = concat(var.office_cidrs_list, data.fastly_ip_ranges.fastly.cidr_blocks)
  rails_assets_s3_regional_domain_name = aws_s3_bucket.rails_assets.bucket_regional_domain_name
  is_live                              = false

  apps_security_config_list = {
    "draft-router" = { security_group_id = module.draft_router.security_group_id, target_port = 80 },
  }
}
