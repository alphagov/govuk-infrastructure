terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.69"
    }
  }
}

# TODO: parameterise hardcoded value
data "aws_vpc" "vpc" {
  id = "vpc-9e62bcf8"
}

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
  container_definitions = jsonencode([
    {
      "name"      = "frontend",
      "image"     = "govuk/frontend:fargate-statsd",
      "essential" = true,
      "environment" = [
        { "name" = "RAILS_ENV", "value" = "production" },
        { "name" = "ASSET_HOST", "value" = "www.gov.uk" },
        { "name" = "GOVUK_APP_DOMAIN", "value" = "www.gov.uk" },
        { "name" = "GOVUK_WEBSITE_ROOT", "value" = "www.gov.uk" },
        { "name" = "WEBSITE_ROOT", "value" = "www.gov.uk" },
        { "name" = "PLEK_SERVICE_CONTENT_STORE_URI", "value" = "https://www.gov.uk/api" },
        { "name" = "PLEK_SERVICE_STATIC_URI", "value" = "https://assets.publishing.service.gov.uk" },
        { "name" = "GOVUK_ASSET_ROOT", "value" = "https://assets.digital.cabinet-office.gov.uk" },
        { "name" = "STATSD_PROTOCOL", "value" = "tcp" },
        { "name" = "STATSD_HOST", "value" = "statsd.test.govuk-internal.digital" },
        { "name" = "GOVUK_STATSD_PREFIX", "value" = "fargate" }
      ],
      "logConfiguration" = {
        "logDriver" = "awslogs",
        "options" = {
          "awslogs-create-group"  = "true",
          "awslogs-group"         = "awslogs-fargate",
          "awslogs-region"        = "eu-west-1",
          "awslogs-stream-prefix" = "awslogs-frontend"
        }
      },
      "portMappings" = [
        {
          "containerPort" = 80,
          "protocol"      = "tcp"
        }
      ],
      "secrets" = [
        {
          "name"      = "SECRET_KEY_BASE",
          "valueFrom" = "arn:aws:secretsmanager:eu-west-1:430354129336:secret:frontend_app-SECRET_KEY_BASE-Em3aWA"
        }
      ]
    },
    {
      "name"  = "envoy",
      "image" = "840364872350.dkr.ecr.eu-west-1.amazonaws.com/aws-appmesh-envoy:v1.15.0.0-prod",
      "user"  = "1337",
      "environment" = [
        { "name" = "APPMESH_VIRTUAL_NODE_NAME", "value" : "mesh/govuk/virtualNode/frontend" },
        { "name" = "ENVOY_LOG_LEVEL", "value" : "debug" }
      ],
      "essential" = true,
      "logConfiguration" = {
        "logDriver" = "awslogs",
        "options" = {
          "awslogs-create-group"  = "true",
          "awslogs-group"         = "awslogs-fargate",
          "awslogs-region"        = "eu-west-1",
          "awslogs-stream-prefix" = "awslogs-frontend-envoy"
        }
      }
    }
  ])
  network_mode       = "awsvpc"
  cpu                = 512
  memory             = 1024
  execution_role_arn = data.aws_iam_role.task_execution_role.arn
  task_role_arn      = data.aws_iam_role.task_role.arn

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"

    properties = {
      AppPorts         = "80"
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
      IgnoredUID       = "1337"
      ProxyEgressPort  = 15001
      ProxyIngressPort = 15000
    }
  }
}

resource "aws_ecs_task_definition" "console_definition" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("${path.module}/frontend_console.json")
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = data.aws_iam_role.task_execution_role.arn
  task_role_arn            = data.aws_iam_role.task_role.arn

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"

    properties = {
      AppPorts         = "80"
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
      var.govuk_management_access_security_group
    ]
    subnets = var.private_subnets
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.service.arn
    container_name = var.service_name
  }
}

resource "aws_security_group" "service" {
  name        = "fargate_${var.service_name}_ingress"
  vpc_id      = data.aws_vpc.vpc.id
  description = "Permit internal services to access the ${var.service_name} ECS service"
}

# TODO: security group rules for dependencies?
