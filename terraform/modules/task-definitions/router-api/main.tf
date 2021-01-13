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
  app_name = "router-api"
}

data "aws_secretsmanager_secret" "oauth_id" {
  name = "${var.service_name}_OAUTH_ID"
}

data "aws_secretsmanager_secret" "oauth_secret" {
  name = "${var.service_name}_OAUTH_SECRET"
}

data "aws_secretsmanager_secret" "secret_key_base" {
  name = "${var.service_name}_SECRET_KEY_BASE"
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
      "image" : "govuk/router-api:${var.image_tag}",
      "essential" : true,
      "environment" : [
        { "name" : "GOVUK_APP_DOMAIN", "value" : var.service_discovery_namespace_name },
        { "name" : "GOVUK_APP_DOMAIN_EXTERNAL", "value" : var.govuk_app_domain_external },
        { "name" : "GOVUK_APP_NAME", "value" : var.service_name },
        { "name" : "GOVUK_APP_ROOT", "value" : "/var/apps/${var.service_name}" },
        { "name" : "GOVUK_STATSD_HOST", "value" : var.statsd_host },
        { "name" : "GOVUK_STATSD_PREFIX", "value" : "govuk.app.${local.app_name}.ecs" },
        { "name" : "GOVUK_STATSD_PROTOCOL", "value" : "tcp" },
        { "name" : "RAILS_ENV", "value" : "production" },
        { "name" : "PLEK_SERVICE_SIGNON_URI", "value" : "https://signon-ecs.${var.govuk_app_domain_external}" },
        { "name" : "PORT", "value" : "80" },
        { "name" : "ROUTER_NODES", "value" : var.router_urls },
        { "name" : "MONGODB_URI", "value" : var.mongodb_url },
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
          "containerPort" : 80,
          "hostPort" : 80,
          "protocol" : "tcp"
        },
      ],
      "secrets" : [
        {
          "name" : "GDS_SSO_OAUTH_ID",
          "valueFrom" : data.aws_secretsmanager_secret.oauth_id.arn
        },
        {
          "name" : "GDS_SSO_OAUTH_SECRET",
          "valueFrom" : data.aws_secretsmanager_secret.oauth_secret.arn
        },
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
