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

locals {
  service_name = "router"
}

module "task_definition" {
  source             = "../../task-definition"
  mesh_name          = var.mesh_name
  service_name       = local.service_name
  cpu                = 512
  memory             = 1024
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = [
    {
      "name" : "router",
      "image" : "govuk/router:${var.image_tag}",
      "essential" : true,
      "environment" : [
        { "name" : "GOVUK_APP_NAME", "value" : "router" },
        { "name" : "GOVUK_APP_ROOT", "value" : "/var/apps/router" },
        { "name" : "ROUTER_APIADDR", "value" : ":8081" },
        { "name" : "ROUTER_BACKEND_HEADER_TIMEOUT", "value" : "20s" },
        { "name" : "ROUTER_PUBADDR", "value" : ":8080" },
        { "name" : "ROUTER_MONGO_DB", "value" : "router" },
        { "name" : "ROUTER_MONGO_URL", "value" : "mongodb://${var.mongodb_host}" },
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
          "awslogs-stream-prefix" : "awslogs-${local.service_name}"
        }
      },
      "mountPoints" : [],
      "portMappings" : [
        {
          "containerPort" : 8080,
          "hostPort" : 8080,
          "protocol" : "tcp"
        },
        {
          "containerPort" : 8081,
          "hostPort" : 8081,
          "protocol" : "tcp"
        }
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
