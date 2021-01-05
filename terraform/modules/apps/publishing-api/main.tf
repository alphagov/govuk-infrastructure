terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

module "web" {
  source                           = "../../app"
  execution_role_arn               = var.execution_role_arn
  vpc_id                           = var.vpc_id
  cluster_id                       = var.cluster_id
  service_name                     = "${var.service_name}-web"
  subnets                          = var.private_subnets
  mesh_name                        = var.mesh_name
  desired_count                    = var.desired_count
  service_discovery_namespace_id   = var.service_discovery_namespace_id
  service_discovery_namespace_name = var.service_discovery_namespace_name
  extra_security_groups            = [var.govuk_management_access_security_group, var.mesh_service_sg_id]
}

module "worker" {
  source                           = "../../app"
  execution_role_arn               = var.execution_role_arn
  vpc_id                           = var.vpc_id
  cluster_id                       = var.cluster_id
  service_name                     = "${var.service_name}-worker"
  subnets                          = var.private_subnets
  mesh_name                        = var.mesh_name
  desired_count                    = var.desired_count
  service_discovery_namespace_id   = var.service_discovery_namespace_id
  service_discovery_namespace_name = var.service_discovery_namespace_name
  extra_security_groups            = [module.web.security_group_id, var.govuk_management_access_security_group, var.mesh_service_sg_id]
}
