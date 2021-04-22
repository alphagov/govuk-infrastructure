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
  container_name          = "app"
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
      container_name   = local.container_name
      container_port   = lb.value["container_port"]
    }
  }

  network_configuration {
    security_groups = local.service_security_groups
    subnets         = var.subnets
  }

  dynamic "service_registries" {
    for_each = var.service_mesh ? [1] : []
    content {
      registry_arn   = module.service_mesh_node[0].discovery_service_arn
      container_name = local.container_name
    }
  }

  # For bootstrapping
  task_definition = aws_ecs_task_definition.bootstrap.arn

  lifecycle {
    # It is essential that we ignore changes to task_definition.
    # If this is removed, the bootstrapping image will be deployed.
    ignore_changes = [task_definition]
  }
}

module "service_mesh_node" {
  # TODO: It looks like service_mesh (bool) is just a snowflake for grafana.
  count = var.service_mesh ? 1 : 0

  source                           = "../service-mesh-node"
  backend_virtual_service_names    = var.backend_virtual_service_names
  mesh_name                        = var.mesh_name
  port                             = var.port
  protocol                         = "http"
  service_discovery_namespace_id   = var.service_discovery_namespace_id
  service_discovery_namespace_name = var.service_discovery_namespace_name
  service_name                     = var.service_name
}

resource "aws_security_group" "service" {
  name        = "fargate_${var.service_name}-${terraform.workspace}"
  vpc_id      = var.vpc_id
  description = "${var.service_name} app ECS tasks"
}
