terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "SENTRY_DSN"
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
  source             = "../../task-definitions/router"
  image_tag          = var.image_tag
  mesh_name          = var.mesh_name
  mongodb_host       = var.mongodb_host
  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn
  sentry_environment = var.sentry_environment
}
