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

data "aws_secretsmanager_secret" "devise_pepper" {
  name = "signon_app-DEVISE_PEPPER"
}

data "aws_secretsmanager_secret" "devise_secret_key" {
  name = "signon_app-DEVISE_SECRET_KEY" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "secret_key_base" {
  name = "signon_app-SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "database_url" {
  name = "signon_app-DATABASE_URL"
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
      "image" : "govuk/signon:${var.image_tag}",
      "essential" : true,
      "environment" : [
        # TODO: Add SSO_PUSH_USER_EMAIL and SPLUNK env vars
        { "name" : "GOVUK_APP_DOMAIN", "value" : var.service_discovery_namespace_name },
        { "name" : "GOVUK_APP_DOMAIN_EXTERNAL", "value" : var.govuk_app_domain_external },
        { "name" : "GOVUK_APP_NAME", "value" : local.service_name },
        { "name" : "GOVUK_APP_ROOT", "value" : "/app" },
        { "name" : "GOVUK_APP_TYPE", "value" : "rack" },
        { "name" : "GOVUK_STATSD_HOST", "value" : var.statsd_host },
        { "name" : "GOVUK_STATSD_PREFIX", "value" : "govuk.app.${local.service_name}.ecs" },
        { "name" : "GOVUK_STATSD_PROTOCOL", "value" : "tcp" },
        { "name" : "GOVUK_WEBSITE_ROOT", "value" : var.govuk_website_root },
        { "name" : "PORT", "value" : "80" },
        { "name" : "RAILS_ENV", "value" : "production" },
        { "name" : "RAILS_SERVE_STATIC_FILES", "value" : "true" }, # TODO: temporary hack
        { "name" : "REDIS_URL", "value" : "redis://${var.redis_host}:${var.redis_port}" },
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
          "containerPort" : 80,
          "hostPort" : 80,
          "protocol" : "tcp"
        },
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
          "name" : "DATABASE_URL",
          "valueFrom" : data.aws_secretsmanager_secret.database_url.arn
        },
        {
          "name" : "DEVISE_PEPPER",
          "valueFrom" : data.aws_secretsmanager_secret.devise_pepper.arn
        },
        {
          "name" : "DEVISE_SECRET_KEY",
          "valueFrom" : data.aws_secretsmanager_secret.devise_secret_key.arn
        }
      ]
    }
  ]
}
