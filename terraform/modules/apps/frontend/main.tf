terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.69"
    }
  }
}

module "task_definition" {
  source                           = "../../task-definitions/frontend"
  service_name                     = var.service_name
  govuk_website_root               = var.govuk_website_root
  image_tag                        = var.image_tag
  mesh_name                        = var.mesh_name
  execution_role_arn               = var.execution_role_arn
  task_role_arn                    = var.task_role_arn
  sentry_environment               = var.sentry_environment
  statsd_host                      = var.statsd_host
  service_discovery_namespace_name = var.service_discovery_namespace_name
  assets_url                       = var.assets_url
  content_store_url                = var.content_store_url
  static_url                       = var.static_url
}

module "app" {
  source                           = "../../app"
  vpc_id                           = var.vpc_id
  cluster_id                       = var.cluster_id
  service_name                     = var.service_name
  subnets                          = var.private_subnets
  mesh_name                        = var.mesh_name
  service_discovery_namespace_id   = var.service_discovery_namespace_id
  service_discovery_namespace_name = var.service_discovery_namespace_name
  task_definition_arn              = module.task_definition.arn
  extra_security_groups            = [var.govuk_management_access_security_group]
}

resource "aws_security_group" "service" {
  name        = "fargate_${var.service_name}_ingress"
  vpc_id      = var.vpc_id
  description = "Permit internal services to access the ${var.service_name} ECS service"
}
