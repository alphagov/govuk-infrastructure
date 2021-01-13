terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

module "app" {
  source                           = "../../app"
  execution_role_arn               = var.execution_role_arn
  vpc_id                           = var.vpc_id
  cluster_id                       = var.cluster_id
  service_name                     = var.service_name
  subnets                          = var.private_subnets
  mesh_name                        = var.mesh_name
  desired_count                    = var.desired_count
  service_discovery_namespace_id   = var.service_discovery_namespace_id
  service_discovery_namespace_name = var.service_discovery_namespace_name
  extra_security_groups            = [var.govuk_management_access_security_group, var.mesh_service_sg_id]

  load_balancers = [{
    target_group_arn = module.public_alb.target_group_arn
    container_name   = "signon"
    container_port   = 80
  }]
}

module "public_alb" {
  source = "../../public-load-balancer"

  app_name                  = var.service_name
  vpc_id                    = var.vpc_id
  dns_a_record_name         = "${var.service_name}-ecs"
  public_subnets            = var.public_subnets
  app_domain                = var.public_lb_domain_name # TODO: Change to app_domain
  public_lb_domain_name     = var.public_lb_domain_name
  workspace_suffix          = "govuk" # TODO: Changeme
  service_security_group_id = module.app.security_group_id
}
