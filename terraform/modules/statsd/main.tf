terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

locals {
  ingress_port = 8125
  service_name = "statsd"
}

resource "aws_ecs_service" "statsd" {
  name          = local.service_name
  cluster       = var.cluster_id
  launch_type   = "FARGATE"
  desired_count = 1

  network_configuration {
    security_groups = concat([aws_security_group.service.id], var.security_groups)
    subnets         = var.private_subnets
  }

  service_registries {
    registry_arn   = module.service_mesh_node.discovery_service_arn
    container_name = local.service_name
  }

  task_definition = module.task_definition.arn
}

module "service_mesh_node" {
  mesh_name                        = var.mesh_name
  backend_virtual_service_names    = [] # TODO: Nice to have Graphite as a virtual node (for retries etc)
  port                             = local.ingress_port
  protocol                         = "tcp"
  service_discovery_namespace_id   = var.service_discovery_namespace_id
  service_discovery_namespace_name = var.service_discovery_namespace_name
  service_name                     = local.service_name
  source                           = "../service-mesh-node"
}

module "task_definition" {
  source                  = "../task-definition"
  mesh_name               = var.mesh_name
  service_name            = local.service_name
  cpu                     = 512
  memory                  = 1024
  execution_role_arn      = var.execution_role_arn
  task_role_arn           = var.task_role_arn
  container_ingress_ports = local.ingress_port

  # TODO: Use app-container-definition
  container_definitions = [
    {
      "name" : local.service_name,
      "image" : "govuk/statsd:test-0.1.3", # TODO: hardcoded image tag
      "essential" : true,
      "dependsOn" : [{
        "containerName" : "envoy",
        "condition" : "START"
      }],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "awslogs-fargate",
          "awslogs-region" : "eu-west-1",                           # TODO: hard coded
          "awslogs-stream-prefix" : "awslogs-${local.service_name}" # TODO: should this be cluster-aware?
        }
      },
      "mountPoints" : [],
      "portMappings" : [
        {
          "containerPort" : local.ingress_port,
          "protocol" : "tcp"
        }
      ]
    }
  ]
}

resource "aws_security_group" "service" {
  name        = "fargate_${local.service_name}-${terraform.workspace}"
  vpc_id      = var.vpc_id
  description = "${local.service_name} ECS Service"
}
