terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.69"
    }
  }
}

data "aws_secretsmanager_secret" "oauth_id" {
  name = "content_store_app-OAUTH_ID"
}
data "aws_secretsmanager_secret" "oauth_secret" {
  name = "content_store_app-OAUTH_SECRET"
}
data "aws_secretsmanager_secret" "publishing_api_bearer_token" {
  name = "content_store_app-PUBLISHING_API_BEARER_TOKEN" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "router_api_bearer_token" {
  name = "content_store_app-ROUTER_API_BEARER_TOKEN" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "secret_key_base" {
  name = "content_store_app-SECRET_KEY_BASE" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "content_store_app-SENTRY_DSN"
}

module "app" {
  source                                   = "../../app"
  cpu                                      = "512"
  memory                                   = "1024"
  vpc_id                                   = var.vpc_id
  cluster_id                               = var.cluster_id
  service_name                             = var.service_name
  private_subnets                          = var.private_subnets
  govuk_publishing_platform_namespace_id   = var.govuk_publishing_platform_namespace_id
  govuk_publishing_platform_namespace_name = var.govuk_publishing_platform_namespace_name
  task_role_arn                            = var.task_role_arn
  execution_role_arn                       = var.execution_role_arn
  extra_security_groups                    = [var.govuk_management_access_security_group]
  container_definitions = [
    {
      "name" : "content-store",
      "image" : "govuk/content-store:with-content-schemas",
      "essential" : true,
      "environment" : [
        { "name" : "APPMESH_VIRTUAL_NODE_NAME", "value" : "mesh/govuk/virtualNode/content-store" },
        { "name" : "DEFAULT_TTL", "value" : "1800" },
        { "name" : "GOVUK_APP_DOMAIN", "value" : "test.govuk-internal.digital" },
        { "name" : "GOVUK_APP_DOMAIN_EXTERNAL", "value" : "test.govuk.digital" },
        { "name" : "GOVUK_APP_NAME", "value" : "content-store" },
        { "name" : "GOVUK_APP_TYPE", "value" : "rack" },
        { "name" : "GOVUK_CONTENT_SCHEMAS_PATH", "value" : "/govuk-content-schemas" },
        { "name" : "GOVUK_GROUP", "value" : "deploy" },
        { "name" : "GOVUK_STATSD_PREFIX", "value" : "fargate" },
        { "name" : "GOVUK_USER", "value" : "deploy" },
        { "name" : "GOVUK_WEBSITE_ROOT", "value" : "test.publishing.service.gov.uk" },
        { "name" : "MONGODB_URI", "value" : "mongodb://mongo-1.test.govuk-internal.digital,mongo-2.test.govuk-internal.digital,mongo-3.test.govuk-internal.digital/content_store_production" },
        { "name" : "PLEK_SERVICE_PERFORMANCEPLATFORM_BIG_SCREEN_VIEW_URI", "value" : "" },
        { "name" : "PLEK_SERVICE_PUBLISHING_API_URI", "value" : "http://publishing-api.mesh.govuk-internal.digital" },
        { "name" : "PLEK_SERVICE_RUMMAGER_URI", "value" : "" },
        { "name" : "PLEK_SERVICE_SPOTLIGHT_URI", "value" : "" },
        { "name" : "PORT", "value" : "80" },
        { "name" : "RAILS_ENV", "value" : "production" },
        { "name" : "STATSD_PROTOCOL", "value" : "tcp" },
        { "name" : "STATSD_HOST", "value" : "statsd.test.govuk-internal.digital" },
        { "name" : "UNICORN_WORKER_PROCESSES", "value" : "12" }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "awslogs-fargate",
          "awslogs-region" : "eu-west-1",
          "awslogs-stream-prefix" : "awslogs-content-store"
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
          "name" : "OAUTH_ID",
          "valueFrom" : data.aws_secretsmanager_secret.oauth_id.arn
        },
        {
          "name" : "OAUTH_SECRET",
          "valueFrom" : data.aws_secretsmanager_secret.oauth_secret.arn
        },
        {
          "name" : "PUBLISHING_API_BEARER_TOKEN",
          "valueFrom" : data.aws_secretsmanager_secret.publishing_api_bearer_token.arn
        },
        {
          "name" : "ROUTER_API_BEARER_TOKEN",
          "valueFrom" : data.aws_secretsmanager_secret.router_api_bearer_token.arn
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
