# modules/app defines a set of resources which are essential to every
# microservice in the system. If a resource is not common to all apps,
# it probably doesn't belong here.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

locals {
  subdomain               = var.service_name
  container_services      = "${length(var.custom_container_services) == 0 ? [{ container_service = "${local.subdomain}", port = 80, protocol = "http" }] : var.custom_container_services}"
  service_security_groups = concat([aws_security_group.service.id], var.extra_security_groups)
}

resource "aws_ecs_service" "service" {
  name        = var.service_name
  cluster     = var.cluster_id
  launch_type = "FARGATE"

  desired_count = var.desired_count

  health_check_grace_period_seconds = length(var.load_balancers) > 0 ? var.health_check_grace_period_seconds : null

  dynamic "load_balancer" {
    for_each = var.load_balancers
    iterator = lb
    content {
      target_group_arn = lb.value["target_group_arn"]
      container_name   = lb.value["container_name"]
      container_port   = lb.value["container_port"]
    }
  }

  network_configuration {
    security_groups = local.service_security_groups
    subnets         = var.subnets
  }

  service_registries {
    registry_arn   = module.service_mesh_node[0].discovery_service_arn
    container_name = var.service_name
  }

  # For bootstrapping
  task_definition = module.bootstrap_task_definition.arn

  lifecycle {
    # It is essential that we ignore changes to task_definition.
    # If this is removed, the bootstrapping image will be deployed.
    ignore_changes = [task_definition]
  }
}

module "bootstrap_task_definition" {
  service_name       = var.service_name
  execution_role_arn = var.execution_role_arn
  source             = "../task-definitions/bootstrap"
}

module "service_mesh_node" {
  count = length(local.container_services)

  source                           = "../service-mesh-node"
  mesh_name                        = var.mesh_name
  port                             = local.container_services[count.index].port
  protocol                         = local.container_services[count.index].protocol
  service_discovery_namespace_id   = var.service_discovery_namespace_id
  service_discovery_namespace_name = var.service_discovery_namespace_name
  service_name                     = local.container_services[count.index].container_service
}

resource "aws_security_group" "service" {
  name        = "fargate_${var.service_name}"
  vpc_id      = var.vpc_id
  description = "${var.service_name} app ECS tasks"
}
