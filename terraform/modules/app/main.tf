# modules/app defines a set of resources which are essential to every
# microservice in the system. If a resource is not common to all apps,
# it probably doesn't belong here.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.69"
    }
  }
}

locals {
  container_definitions = [
    {
      "name" : "envoy",
      # TODO: don't hardcode the version; track stable Envoy
      # TODO: control when Envoy updates happen (but still needs to be automatic)
      # TODO: don't hardcode the region
      "image" : "840364872350.dkr.ecr.eu-west-1.amazonaws.com/aws-appmesh-envoy:v1.15.0.0-prod",
      "user" : "1337",
      "environment" : [
        { "name" : "APPMESH_VIRTUAL_NODE_NAME", "value" : "mesh/${var.appmesh_id}/virtualNode/${var.service_name}" }
      ],
      "essential" : true,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "awslogs-fargate",
          "awslogs-region" : "eu-west-1", # TODO: hardcoded
          "awslogs-stream-prefix" : "awslogs-${var.service_name}-envoy"
        }
      }
    }
  ]
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  container_definitions    = jsonencode(concat(var.container_definitions, local.container_definitions))
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"

    properties = {
      AppPorts         = var.container_ingress_port
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254" # TODO: no longer required (try omitting, might need to stay but empty?)
      # TODO: what are these magic numbers and are they necessary?
      IgnoredUID       = "1337"
      ProxyEgressPort  = 15001
      ProxyIngressPort = 15000
    }
  }
}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = concat([aws_security_group.service.id], var.extra_security_groups)
    subnets         = var.private_subnets
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.service.arn
    container_name = var.service_name
  }
}

resource "aws_security_group" "service" {
  name        = "fargate_${var.service_name}"
  vpc_id      = var.vpc_id
  description = "${var.service_name} app ECS tasks"
}
