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
  custom_container_services        = [{ container_service = var.service_name, port = 80, protocol = "tcp" }, { container_service = "${var.service_name}-reload", port = 3055, protocol = "tcp" }]
}
