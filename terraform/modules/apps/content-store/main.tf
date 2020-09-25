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
  name = "content_store_app-PUBLISHING_API_BEARER_TOKEN"
}
data "aws_secretsmanager_secret" "router_api_bearer_token" {
  name = "content_store_app-ROUTER_API_BEARER_TOKEN"
}
data "aws_secretsmanager_secret" "secret_key_base" {
  name = "content_store_app-SECRET_KEY_BASE"
}
data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "content_store_app-SENTRY_DSN"
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
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
    },
    {
      "name" : "envoy",
      "image" : "840364872350.dkr.ecr.eu-west-1.amazonaws.com/aws-appmesh-envoy:v1.15.0.0-prod",
      "user" : "1337",
      "environment" : [
        { "name" : "APPMESH_VIRTUAL_NODE_NAME", "value" : "mesh/govuk/virtualNode/content-store" },
        { "name" : "ENVOY_LOG_LEVEL", "value" : "debug" }
      ],
      "essential" : true,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "awslogs-fargate",
          "awslogs-region" : "eu-west-1",
          "awslogs-stream-prefix" : "awslogs-content-store-envoy"
        }
      }
    }
  ])
  network_mode       = "awsvpc"
  cpu                = 512
  memory             = 1024
  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"

    properties = {
      AppPorts         = var.container_ingress_port
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
      IgnoredUID       = "1337"
      ProxyEgressPort  = 15001
      ProxyIngressPort = 15000
    }
  }
}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [
      aws_security_group.service.id,
      var.govuk_management_access_security_group,
      data.aws_security_group.service_dependencies.id,
      aws_security_group.dependencies.id
    ]
    subnets = var.private_subnets
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.service.arn
    container_name = var.service_name
  }
}

#
# ECS Service Security groups
#

resource "aws_security_group" "service" {
  name        = "fargate_${var.service_name}_ingress"
  vpc_id      = var.vpc_id
  description = "Permit internal services to access the ${var.service_name} ECS service"
}

resource "aws_security_group" "dependencies" {
  name        = "fargate_${var.service_name}_app"
  vpc_id      = var.vpc_id
  description = "Allows ingress from ${var.service_name} to its dependencies"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "service_ingress" {
  description = "Allow content-store ingress to publishing-api"
  type        = "ingress"
  from_port   = "80"
  to_port     = "80"
  protocol    = "tcp"

  security_group_id        = var.publishing_api_ingress_security_group
  source_security_group_id = aws_security_group.dependencies.id
}

data "aws_security_group" "service_dependencies" {
  id = "sg-0fa32025e3d7af478" # govuk_content-store_access
}
