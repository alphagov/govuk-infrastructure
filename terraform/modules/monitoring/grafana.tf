locals {
  service_name = "grafana"
}

module "grafana_app" {
  source                        = "../app"
  image_name                    = "grafana"
  registry                      = "grafana"
  vpc_id                        = var.vpc_id
  backend_virtual_service_names = []
  cluster_id                    = aws_ecs_cluster.cluster.id
  service_name                  = local.service_name
  subnets                       = var.private_subnets
  extra_security_groups         = [var.govuk_management_access_sg_id]
  desired_count                 = var.desired_count
  load_balancers = [{
    target_group_arn = module.grafana_public_alb.target_group_arn
    container_port   = 3000
  }]
  environment_variables   = {} # TODO
  secrets_from_arns       = {} # TODO
  splunk_url_secret_arn   = var.splunk_url_secret_arn
  splunk_token_secret_arn = var.splunk_token_secret_arn
  splunk_sourcetype       = var.splunk_sourcetype
  splunk_index            = var.splunk_index
  aws_region              = data.aws_region.current.name
  cpu                     = 512
  memory                  = 1024
  port                    = 3000
  task_role_arn           = aws_iam_role.monitoring_execution.arn # TODO - use a separate role for this?
  execution_role_arn      = aws_iam_role.monitoring_execution.arn
}

data "aws_acm_certificate" "public_lb_alternate" {
  domain   = "*.${var.external_app_domain}"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "public" {
  name = var.external_app_domain
}

module "grafana_public_alb" {
  source = "../public-load-balancer"

  app_name                  = "grafana"
  vpc_id                    = var.vpc_id
  public_zone_id            = data.aws_route53_zone.public
  dns_a_record_name         = "${local.service_name}-ecs"
  public_subnets            = var.public_subnets
  external_app_domain       = var.external_app_domain
  certificate               = data.aws_acm_certificate.public_lb_alternate
  publishing_service_domain = var.publishing_service_domain
  workspace                 = "govuk" # TODO: Changeme
  service_security_group_id = module.grafana_app.security_group_id
  health_check_path         = "/api/health"
  target_port               = 3000
  allowlist_cidrs           = var.grafana_cidrs_allow_list
}
