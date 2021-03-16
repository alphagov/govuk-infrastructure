module "www_origin" {
  source = "../../modules/origin"

  vpc_id                               = local.vpc_id
  aws_region                           = data.aws_region.current.name
  public_subnets                       = local.public_subnets
  public_zone_id                       = aws_route53_zone.workspace_public.zone_id
  external_app_domain                  = local.workspace_external_domain
  certificate                          = aws_acm_certificate.workspace_public.arn
  publishing_service_domain            = var.publishing_service_domain
  workspace_suffix                     = terraform.workspace == "default" ? "govuk" : terraform.workspace
  external_cidrs_list                  = concat(var.office_cidrs_list, data.fastly_ip_ranges.fastly.cidr_blocks)
  rails_assets_s3_regional_domain_name = aws_s3_bucket.rails_assets.bucket_regional_domain_name

  apps_security_config_list = {
    "frontend" = { security_group_id = module.frontend.security_group_id, target_port = 80 },
  }
}

module "draft_origin" {
  source = "../../modules/origin"

  vpc_id                               = local.vpc_id
  aws_region                           = data.aws_region.current.name
  public_subnets                       = local.public_subnets
  public_zone_id                       = aws_route53_zone.workspace_public.zone_id
  external_app_domain                  = local.workspace_external_domain
  certificate                          = aws_acm_certificate.workspace_public.arn
  publishing_service_domain            = var.publishing_service_domain
  workspace_suffix                     = terraform.workspace == "default" ? "govuk" : terraform.workspace
  external_cidrs_list                  = concat(var.office_cidrs_list, data.fastly_ip_ranges.fastly.cidr_blocks)
  rails_assets_s3_regional_domain_name = aws_s3_bucket.rails_assets.bucket_regional_domain_name
  live                                 = false

  apps_security_config_list = {
    "draft-frontend" = { security_group_id = module.draft_frontend.security_group_id, target_port = 80 },
  }
}
