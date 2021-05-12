module "grafana_public_alb" {
  source = "../public-load-balancer"

  app_name                  = "grafana"
  vpc_id                    = var.vpc_id
  public_zone_id            = aws_route53_zone.monitoring_public.zone_id
  dns_a_record_name         = local.grafana_service_name
  public_subnets            = var.public_subnets
  external_app_domain       = local.monitoring_external_domain
  certificate               = aws_acm_certificate_validation.monitoring_public.certificate_arn
  publishing_service_domain = var.publishing_service_domain
  workspace                 = var.workspace
  service_security_group_id = aws_security_group.grafana.id
  health_check_path         = "/api/health"
  target_port               = var.grafana_port
  allowlist_cidrs           = var.grafana_cidrs_allow_list
  environment               = var.govuk_environment
}
