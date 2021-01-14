locals {
  service_name = "grafana"
}

module "grafana_app" {
  source                    = "../app"
  execution_role_arn        = aws_iam_role.monitoring_execution.arn
  vpc_id                    = var.vpc_id
  cluster_id                = aws_ecs_cluster.cluster.id
  service_name              = local.service_name
  subnets                   = var.private_subnets
  extra_security_groups     = [var.govuk_management_access_sg_id]
  service_mesh              = false
  desired_count             = var.desired_count
  custom_container_services = [{ container_service = local.service_name, port = 3000, protocol = "http" }]

  load_balancers = [{
    target_group_arn = module.grafana_public_alb.target_group_arn
    container_name   = local.service_name
    container_port   = 3000
  }]
}

module "grafana_public_alb" {
  source = "../public-load-balancer"

  app_name                  = "grafana"
  vpc_id                    = var.vpc_id
  dns_a_record_name         = "${local.service_name}-ecs"
  public_subnets            = var.public_subnets
  app_domain                = var.public_lb_domain_name # TODO: Change to app_domain
  public_lb_domain_name     = var.public_lb_domain_name
  workspace_suffix          = "govuk" # TODO: Changeme
  service_security_group_id = module.grafana_app.security_group_id
  health_check_path         = "/api/health"
  target_port               = 3000
  external_cidrs_list       = var.grafana_cidrs_allow_list
}
