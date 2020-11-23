terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = var.assume_role_arn
  }
}

data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "SENTRY_DSN"
}

module "task_definition" {
  source                  = "../../task-definition"
  mesh_name               = var.mesh_name
  service_name            = var.service_name
  cpu                     = 512
  memory                  = 1024
  execution_role_arn      = var.execution_role_arn
  task_role_arn           = var.task_role_arn
  container_ingress_ports = "3056"

  container_definitions = [
    {
      "name" : var.service_name,
      "image" : "govuk/router-api:${var.image_tag}",
      "essential" : true,
      "environment" : [
        { "name" : "APPMESH_RESOURCE_ARN", "value" : "mesh/${var.mesh_name}/virtualNode/${var.service_name}" },
        { "name" : "GOVUK_APP_NAME", "value" : var.service_name },
        { "name" : "GOVUK_APP_ROOT", "value" : "/var/apps/${var.service_name}" },
        { "name" : "GOVUK_STATSD_PREFIX", "value" : "fargate" },
        { "name" : "PORT", "value" : "3056" },
        { "name" : "ROUTER_NODES", "value" : var.router_urls },
        { "name" : "MONGO_URI", "value" : var.mongodb_url },
        { "name" : "SENTRY_ENVIRONMENT", "value" : var.sentry_environment }
      ],
      "dependsOn" : [{
        "containerName" : "envoy",
        "condition" : "START"
      }],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "awslogs-fargate",
          "awslogs-region" : "eu-west-1",
          "awslogs-stream-prefix" : "awslogs-${var.service_name}"
        }
      },
      "mountPoints" : [],
      "portMappings" : [
        {
          "containerPort" : 3056,
          "hostPort" : 3056,
          "protocol" : "tcp"
        },
      ],
      "secrets" : [
        {
          "name" : "SENTRY_DSN",
          "valueFrom" : data.aws_secretsmanager_secret.sentry_dsn.arn
        }
      ]
    }
  ]
}
