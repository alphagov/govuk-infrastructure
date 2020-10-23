terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.69"
    }
  }
}

data "aws_secretsmanager_secret" "secret_key_base" {
  name = "frontend_app-SECRET_KEY_BASE"
}

data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "SENTRY_DSN"
}

module "app" {
  source                           = "../../app"
  cpu                              = 512
  memory                           = 1024
  vpc_id                           = var.vpc_id
  cluster_id                       = var.cluster_id
  service_name                     = var.service_name
  subnets                          = var.private_subnets
  mesh_name                        = var.mesh_name
  service_discovery_namespace_id   = var.service_discovery_namespace_id
  service_discovery_namespace_name = var.service_discovery_namespace_name
  task_role_arn                    = var.task_role_arn
  execution_role_arn               = var.execution_role_arn
  extra_security_groups            = [var.govuk_management_access_security_group]
  container_definitions = [
    {

      "name" : "frontend",
      "image" : "govuk/frontend:fargate-statsd",
      "essential" : true,
      "environment" : [
        { "name" : "RAILS_ENV", "value" : "production" },
        { "name" : "ASSET_HOST", "value" : "www.gov.uk" },
        { "name" : "GOVUK_APP_DOMAIN", "value" : "www.gov.uk" },
        { "name" : "GOVUK_WEBSITE_ROOT", "value" : "www.gov.uk" },
        { "name" : "WEBSITE_ROOT", "value" : "www.gov.uk" },
        { "name" : "PLEK_SERVICE_CONTENT_STORE_URI", "value" : "https://www.gov.uk/api" },
        { "name" : "PLEK_SERVICE_STATIC_URI", "value" : "https://assets.publishing.service.gov.uk" },
        { "name" : "GOVUK_ASSET_ROOT", "value" : "https://assets.digital.cabinet-office.gov.uk" },
        { "name" : "STATSD_PROTOCOL", "value" : "tcp" },
        { "name" : "STATSD_HOST", "value" : "statsd.test.govuk-internal.digital" },
        { "name" : "GOVUK_STATSD_PREFIX", "value" : "fargate" }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "awslogs-fargate",
          "awslogs-region" : "eu-west-1",
          "awslogs-stream-prefix" : "awslogs-frontend"
        }
      },
      "mountPoints" : [],
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
        }
      ]
    }
  ]
}
