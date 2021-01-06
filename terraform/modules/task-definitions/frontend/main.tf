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

locals {
  app_name = "frontend"
}

data "aws_secretsmanager_secret" "secret_key_base" {
  name = "frontend_app-SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "publishing_api_bearer_token" {
  name = "frontend_app_PUBLISHING_API_BEARER_TOKEN" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "SENTRY_DSN"
}

module "task_definition" {
  source             = "../../task-definition"
  mesh_name          = var.mesh_name
  service_name       = var.service_name
  cpu                = 1024
  memory             = 2048
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
        { "name" : "GOVUK_APP_DOMAIN_EXTERNAL", "value" : var.govuk_app_domain_external },
        { "name" : "GOVUK_STATSD_HOST", "value" : var.statsd_host },
        { "name" : "GOVUK_STATSD_PREFIX", "value" : "govuk.app.${local.app_name}.ecs" },
        { "name" : "GOVUK_STATSD_PROTOCOL", "value" : "tcp" },
        { "name" : "GOVUK_WEBSITE_ROOT", "value" : var.govuk_website_root },
        { "name" : "WEBSITE_ROOT", "value" : var.govuk_website_root },
        { "name" : "PORT", "value" : "80" },
        { "name" : "PLEK_SERVICE_CONTENT_STORE_URI", "value" : var.content_store_url },
        { "name" : "PLEK_SERVICE_STATIC_URI", "value" : var.static_url },
        { "name" : "PLEK_SERVICE_PUBLISHING_API_URI", "value" : "http://publishing-api-web.${var.service_discovery_namespace_name}" },
        { "name" : "PLEK_SERVICE_SIGNON_URI", "value" : "https://signon-ecs.${var.govuk_app_domain_external}" },
        { "name" : "GOVUK_ASSET_ROOT", "value" : var.assets_url },
        { "name" : "SENTRY_ENVIRONMENT", "value" : var.sentry_environment },
        # TODO: Setting RAILS_SERVE_STATIC_FILES, RAILS_SERVE_STATIC_ASSETS and HEROKU_APP_NAME are temporary workarounds for serving static assets.
        # Remove them once we have a production solution for assets.
        { "name" : "RAILS_SERVE_STATIC_FILES", "value" : "yes" },
        { "name" : "RAILS_SERVE_STATIC_ASSETS", "value" : "yes" },
        { "name" : "HEROKU_APP_NAME", "value" : var.service_name },
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
          "hostPort" : 80,
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
        },
        {
          "name" : "PUBLISHING_API_BEARER_TOKEN",
          "valueFrom" : data.aws_secretsmanager_secret.publishing_api_bearer_token.arn
        }
      ]
    }
  ]
}
