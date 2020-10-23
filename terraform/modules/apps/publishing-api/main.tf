terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.69"
    }
  }
}

data "aws_secretsmanager_secret" "content_store_bearer_token" {
  name = "publishing_api_app-CONTENT_STORE_BEARER_TOKEN"
}

data "aws_secretsmanager_secret" "database_url" {
  name = "publishing_api_app-DATABASE_URL"
}

data "aws_secretsmanager_secret" "draft_content_store_bearer_token" {
  name = "publishing_api_app-DRAFT_CONTENT_STORE_BEARER_TOKEN"
}

data "aws_secretsmanager_secret" "event_log_aws_secret_key" {
  name = "publishing_api_app-EVENT_LOG_AWS_SECRET_KEY"
}

data "aws_secretsmanager_secret" "oauth_id" {
  name = "publishing_api_app-OAUTH_ID"
}

data "aws_secretsmanager_secret" "oauth_secret" {
  name = "publishing_api_app-OAUTH_SECRET"
}

data "aws_secretsmanager_secret" "rabbitmq_password" {
  name = "publishing_api_app-RABBITMQ_PASSWORD"
}

data "aws_secretsmanager_secret" "router_api_bearer_token" {
  name = "publishing_api_app-ROUTER_API_BEARER_TOKEN"
}

data "aws_secretsmanager_secret" "secret_key_base" {
  name = "publishing_api_app-SECRET_KEY_BASE"
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
      "name" : var.service_name,
      "image" : "govuk/${var.service_name}:with-content-schemas",
      "essential" : true,
      "environment" : [
        # TODO: factor our hardcoded stuff
        { "name" : "APPMESH_VIRTUAL_NODE_NAME", "value" : "mesh/${var.mesh_name}/virtualNode/${var.service_name}" },
        { "name" : "CONTENT_API_PROTOTYPE", "value" : "yes" },
        { "name" : "CONTENT_STORE", "value" : "http://content-store.${var.service_discovery_namespace_name}" },
        { "name" : "DRAFT_CONTENT_STORE", "value" : "https://draft-content-store.${var.service_discovery_namespace_name}" },
        { "name" : "EVENT_LOG_AWS_ACCESS_ID", "value" : "AKIAJE6VSW25CYBUMQJA" },
        { "name" : "EVENT_LOG_AWS_BUCKETNAME", "value" : "govuk-${var.service_name}-event-log-test" },
        { "name" : "EVENT_LOG_AWS_USERNAME", "value" : "govuk-${var.service_name}-event-log_user" },
        { "name" : "DEFAULT_TTL", "value" : "1800" },
        { "name" : "GOVUK_APP_DOMAIN", "value" : var.service_discovery_namespace_name },
        { "name" : "GOVUK_APP_DOMAIN_EXTERNAL", "value" : var.govuk_app_domain_external },
        { "name" : "GOVUK_APP_NAME", "value" : "publishing-api" },
        { "name" : "GOVUK_APP_TYPE", "value" : "rack" },
        { "name" : "GOVUK_CONTENT_SCHEMAS_PATH", "value" : "/govuk-content-schemas" },
        { "name" : "GOVUK_GROUP", "value" : "deploy" }, # TODO: clean up?
        { "name" : "GOVUK_STATSD_PREFIX", "value" : "fargate" },
        { "name" : "GOVUK_USER", "value" : "deploy" }, # TODO: clean up?
        { "name" : "GOVUK_WEBSITE_ROOT", "value" : var.govuk_website_root },
        { "name" : "PLEK_SERVICE_CONTENT_STORE_URI", "value" : "http://content-store.${var.service_discovery_namespace_name}" },
        { "name" : "PORT", "value" : "80" },
        { "name" : "RABBITMQ_HOSTS", "value" : "rabbitmq.${var.govuk_app_domain_internal}" },
        { "name" : "RABBITMQ_USER", "value" : "publishing_api" },
        { "name" : "RABBITMQ_VHOST", "value" : "/" },
        { "name" : "REDIS_HOST", "value" : var.redis_host },
        { "name" : "REDIS_PORT", "value" : tostring(var.redis_port) },
        { "name" : "REDIS_URL", "value" : "redis://${var.redis_host}:${var.redis_port}" },
        { "name" : "RAILS_ENV", "value" : "production" },
        { "name" : "STATSD_PROTOCOL", "value" : "tcp" },
        { "name" : "STATSD_HOST", "value" : var.statsd_host },
        { "name" : "UNICORN_WORKER_PROCESSES", "value" : "8" }
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
        }
      ],
      "secrets" : [
        {
          "name" : "CONTENT_STORE_BEARER_TOKEN",
          "valueFrom" : data.aws_secretsmanager_secret.content_store_bearer_token.arn
        },
        {
          "name" : "DATABASE_URL",
          "valueFrom" : data.aws_secretsmanager_secret.database_url.arn
        },
        {
          "name" : "DRAFT_CONTENT_STORE_BEARER_TOKEN",
          "valueFrom" : data.aws_secretsmanager_secret.draft_content_store_bearer_token.arn
        },
        {
          "name" : "EVENT_LOG_AWS_SECRET_KEY",
          "valueFrom" : data.aws_secretsmanager_secret.event_log_aws_secret_key.arn
        },
        {
          "name" : "OAUTH_ID",
          "valueFrom" : data.aws_secretsmanager_secret.oauth_id.arn
        },
        {
          "name" : "OAUTH_SECRET",
          "valueFrom" : data.aws_secretsmanager_secret.oauth_secret.arn
        },
        {
          "name" : "RABBITMQ_PASSWORD",
          "valueFrom" : data.aws_secretsmanager_secret.rabbitmq_password.arn
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
