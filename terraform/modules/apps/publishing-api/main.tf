terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0"
    }
  }
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
  extra_security_groups            = [var.govuk_management_access_security_group]
  task_definition_arn              = module.task_definition.arn
}

module "task_definition" {
  source                           = "../../task-definitions/publishing-api"
  image_tag                        = var.image_tag
  govuk_app_domain_external        = var.govuk_app_domain_external
  govuk_app_domain_internal        = var.govuk_app_domain_internal
  govuk_website_root               = var.govuk_website_root
  mesh_name                        = var.mesh_name
  redis_host                       = var.redis_host
  sentry_environment               = var.sentry_environment
  service_discovery_namespace_name = var.service_discovery_namespace_name
  statsd_host                      = var.statsd_host
  task_role_arn                    = var.task_role_arn
  execution_role_arn               = var.execution_role_arn
}
