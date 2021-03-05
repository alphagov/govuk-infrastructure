module "www_origin" {
  source = "../../modules/origin"

  vpc_id                    = local.vpc_id
  public_subnets            = local.public_subnets
  public_zone_id            = aws_route53_zone.workspace_public.zone_id
  external_app_domain       = var.external_app_domain
  publishing_service_domain = var.publishing_service_domain
  workspace_suffix          = "${terraform.workspace == "default" ? "govuk" : "${terraform.workspace}"}"
  external_cidrs_list       = concat(var.office_cidrs_list, data.fastly_ip_ranges.fastly.cidr_blocks)

  apps_security_config_list = {
    "frontend" = { security_group_id = module.frontend.security_group_id, target_port = 80 },
    "static"   = { security_group_id = module.static.security_group_id, target_port = 80 },
  }
}

module "draft_origin" {
  source = "../../modules/origin"

  vpc_id                    = local.vpc_id
  public_subnets            = local.public_subnets
  public_zone_id            = aws_route53_zone.workspace_public.zone_id
  external_app_domain       = var.external_app_domain
  publishing_service_domain = var.publishing_service_domain
  workspace_suffix          = "${terraform.workspace == "default" ? "govuk" : "${terraform.workspace}"}"
  external_cidrs_list       = concat(var.office_cidrs_list, data.fastly_ip_ranges.fastly.cidr_blocks)
  live                      = false

  apps_security_config_list = {
    "draft-frontend" = { security_group_id = module.draft_frontend.security_group_id, target_port = 80 },
    "draft-static"   = { security_group_id = module.draft_static.security_group_id, target_port = 80 }
  }
}
