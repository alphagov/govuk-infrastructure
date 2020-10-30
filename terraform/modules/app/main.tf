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

resource "aws_ecs_service" "service" {
  name        = var.service_name
  cluster     = var.cluster_id
  launch_type = "FARGATE"

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
    security_groups = concat([aws_security_group.service.id], var.extra_security_groups)
    subnets         = var.subnets
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.service.arn
    container_name = var.service_name
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_security_group" "service" {
  name        = "fargate_${var.service_name}"
  vpc_id      = var.vpc_id
  description = "${var.service_name} app ECS tasks"
}
