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
  app_name = "static"
}

data "aws_secretsmanager_secret" "ga_universal_id" {
  name = "GA_UNIVERSAL_ID"
}

data "aws_secretsmanager_secret" "publishing_api_bearer_token" {
  name = "${var.service_name}_PUBLISHING_API_BEARER_TOKEN" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "secret_key_base" {
  name = "${var.service_name}_SECRET_KEY_BASE" # pragma: allowlist secret
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
  container_ingress_ports = "80"

  container_definitions = [
    {
      "name" : var.service_name,
      "image" : "govuk/static:${var.image_tag}",
      "essential" : true,
      "environment" : [
        { "name" : "GOVUK_APP_NAME", "value" : var.service_name },
        { "name" : "GOVUK_APP_DOMAIN", "value" : var.service_discovery_namespace_name },
        { "name" : "GOVUK_APP_DOMAIN_EXTERNAL", "value" : var.govuk_app_domain_external },
        { "name" : "GOVUK_APP_ROOT", "value" : "/var/apps/${var.service_name}" },
        { "name" : "GOVUK_WEBSITE_ROOT", "value" : var.govuk_website_root },
        { "name" : "GOVUK_STATSD_HOST", "value" : var.statsd_host },
        { "name" : "GOVUK_STATSD_PREFIX", "value" : "govuk.app.${local.app_name}.ecs" },
        { "name" : "GOVUK_STATSD_PROTOCOL", "value" : "tcp" },
        { "name" : "PORT", "value" : "80" },
        { "name" : "ASSET_HOST", "value" : var.assets_url },
        { "name" : "PLEK_SERVICE_ACCOUNT_MANAGER_URI", "value" : "" },
        { "name" : "REDIS_URL", "value" : "redis://${var.redis_host}:${var.redis_port}" },
        { "name" : "SENTRY_ENVIRONMENT", "value" : var.sentry_environment },
        { "name" : "RAILS_ENV", "value" : "production" },
        # TODO: Setting RAILS_SERVE_STATIC_FILES and RAILS_SERVE_STATIC_ASSETS are temporary workarounds for serving static assets.
        # Remove them once we have a production solution for assets.
        { "name" : "RAILS_SERVE_STATIC_FILES", "value" : "enabled" },
        { "name" : "RAILS_SERVE_STATIC_ASSETS", "value" : "yes" },
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
          "containerPort" : 80,
          "hostPort" : 80,
          "protocol" : "tcp"
        },
      ],
      "secrets" : [
        {
          "name" : "SENTRY_DSN",
          "valueFrom" : data.aws_secretsmanager_secret.sentry_dsn.arn
        },
        {
          "name" = "PUBLISHING_API_BEARER",
          "valueFrom" : data.aws_secretsmanager_secret.publishing_api_bearer_token.arn
        },
        {
          "name" = "GA_UNIVERSAL_ID",
          "valueFrom" : data.aws_secretsmanager_secret.ga_universal_id.arn
        },
        {
          "name" = "SECRET_KEY_BASE",
          "valueFrom" : data.aws_secretsmanager_secret.secret_key_base.arn
        },
      ]
    }
  ]
}
