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
}
