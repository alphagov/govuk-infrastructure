terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.69"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_secretsmanager_secret" "secret_key_base" {
  name = "frontend_app-SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "SENTRY_DSN"
}

module "task_definition" {
  source             = "../../task-definition"
  mesh_name          = var.mesh_name
  service_name       = var.service_name
  cpu                = 512
  memory             = 1024
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
  container_definitions = [
    {
      "name" : var.service_name,
      "image" : "govuk/frontend:${var.image_tag}",
      "essential" : true,
      "environment" : [
        { "name" : "RAILS_ENV", "value" : "production" },
        { "name" : "ASSET_HOST", "value" : var.assets_url },
        { "name" : "GOVUK_APP_DOMAIN", "value" : var.service_discovery_namespace_name },
        { "name" : "GOVUK_WEBSITE_ROOT", "value" : var.govuk_website_root },
        { "name" : "WEBSITE_ROOT", "value" : var.govuk_website_root },
        { "name" : "PLEK_SERVICE_CONTENT_STORE_URI", "value" : var.content_store_url },
        { "name" : "PLEK_SERVICE_STATIC_URI", "value" : var.static_url },
        { "name" : "GOVUK_ASSET_ROOT", "value" : var.assets_url },
        { "name" : "SENTRY_ENVIRONMENT", "value" : var.sentry_environment },
        { "name" : "STATSD_PROTOCOL", "value" : "tcp" },
        { "name" : "STATSD_HOST", "value" : var.statsd_host },
        { "name" : "GOVUK_STATSD_PREFIX", "value" : "fargate" }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "awslogs-fargate",
          "awslogs-region" : "eu-west-1",
          "awslogs-stream-prefix" : "awslogs-${var.service_name}"
        }
      },
      "portMappings" : [
        {
          "containerPort" : 80,
          "protocol" : "tcp"
        }
      ],
      "secrets" : [
        {
          "name" : "SECRET_KEY_BASE",
          "valueFrom" : data.aws_secretsmanager_secret.secret_key_base.arn
        },
        {
          "name" : "SENTRY_DSN",
          "valueFrom" : data.aws_secretsmanager_secret.sentry_dsn.arn
        }
      ]
    }
  ]
}
