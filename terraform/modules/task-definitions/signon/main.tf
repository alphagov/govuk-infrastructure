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
  name = "signon_app-SENTRY_DSN"
}

locals {
  service_name = "signon"
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
      "name" : "signon",
      "image" : "govuk/signon:deployed-to-production",
      "essential" : true,
      "environment" : [
        { "name" : "APPMESH_RESOURCE_ARN", "value" : "mesh/${var.mesh_name}/virtualNode/${local.service_name}" },
        { "name" : "GOVUK_APP_NAME", "value" : local.service_name },
        { "name" : "GOVUK_APP_ROOT", "value" : "/app" },
        { "name" : "PORT", "value" : "8080" },
        { "name" : "DATABASE_URL", "value" : var.signon_db_url },
        { "name" : "RAILS_ENV", "value" : "development" },
        { "name" : "TEST_DATABASE_URL", "value" : var.signon_test_db_url },
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
