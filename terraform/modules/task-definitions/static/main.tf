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
  container_ingress_ports = "3013"

  container_definitions = [
    {
      "name" : var.service_name,
      "image" : "govuk/static:${var.image_tag}",
      "essential" : true,
      "environment" : [
        { "name" : "GOVUK_APP_NAME", "value" : var.service_name },
        { "name" : "GOVUK_APP_ROOT", "value" : "/var/apps/${var.service_name}" },
        { "name" : "GOVUK_STATSD_PREFIX", "value" : "fargate" },
        { "name" : "PORT", "value" : "3013" },
        { "name" : "ASSET_HOST", "value" : var.assets_url },
        { "name" : "PLEK_SERVICE_ACCOUNT_MANAGER_URI", "value" : "" },
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
          "awslogs-stream-prefix" : "awslogs-${var.service_name}"
        }
      },
      "mountPoints" : [],
      "portMappings" : [
        {
          "containerPort" : 3013,
          "hostPort" : 3013,
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
      ]
    }
  ]
}
