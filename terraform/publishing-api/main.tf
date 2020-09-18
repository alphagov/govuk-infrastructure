provider "aws" {
  version = "~> 2.69"
  region  = "eu-west-1"
}

#
# Data
#

data "aws_vpc" "vpc" {
  id = "vpc-9e62bcf8"
}

#
# ECS Cluster, Service, Task
#

data "aws_iam_role" "task_execution_role" {
  name = "fargate_task_execution_role"
}

data "aws_iam_role" "task_role" {
  name = "fargate_task_role"
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = "govuk"
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("../task-definitions/publishing-api.json")
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = data.aws_iam_role.task_execution_role.arn
  task_role_arn            = data.aws_iam_role.task_role.arn

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"

    properties = {
      AppPorts         = var.container_ingress_port
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
      IgnoredUID       = "1337"
      ProxyEgressPort  = 15001
      ProxyIngressPort = 15000
    }
  }
}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = data.aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [
      aws_security_group.service.id,
      var.govuk_management_access_security_group,
      data.aws_security_group.service_dependencies.id,
      aws_security_group.dependencies.id
    ]
    subnets = var.private_subnets
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.service.arn
    container_name = var.service_name
  }

  depends_on = [aws_service_discovery_service.service]
}

#
# ECS Service Security groups
#

resource "aws_security_group" "service" {
  name        = "fargate_${var.service_name}_ingress"
  vpc_id      = data.aws_vpc.vpc.id
  description = "Permit internal services to access the ${var.service_name} ECS service"
}

resource "aws_security_group" "dependencies" {
  name        = "fargate_${var.service_name}_app"
  vpc_id      = data.aws_vpc.vpc.id
  description = "Allows ingress from ${var.service_name} to its dependencies"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "service_ingress" {
  description = "Allow publishing-api ingress to content-store"
  type        = "ingress"
  from_port   = "80"
  to_port     = "80"
  protocol    = "tcp"

  security_group_id        = var.content_store_ingress_security_group
  source_security_group_id = aws_security_group.dependencies.id
}

#
# Dependencies
#

data "aws_security_group" "service_dependencies" {
  id = "sg-05ad7398fc0d7c5b4" # legacy govuk-aws group: govuk_publishing-api_access
}
