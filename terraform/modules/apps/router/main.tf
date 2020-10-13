terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.69"
    }
  }
}

data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "router_app-SENTRY_DSN"
}

module "app" {
  source                           = "../../app"
  cpu                              = "512"
  memory                           = "1024"
  vpc_id                           = var.vpc_id
  cluster_id                       = var.cluster_id
  service_name                     = var.service_name
  subnets                          = var.private_subnets
  mesh_name                        = var.mesh_name
  service_discovery_namespace_id   = var.service_discovery_namespace_id
  service_discovery_namespace_name = var.service_discovery_namespace_name
  task_role_arn                    = var.task_role_arn
  execution_role_arn               = var.execution_role_arn
  extra_security_groups            = [var.govuk_management_access_sg_id]
  container_definitions = [
    {
      "name" : "router",
      "image" : "govuk/${var.service_name}:deploy-to-production",
      "essential" : true,
      "environment" : [
        { "name" : "GOVUK_APP_NAME", "value" : "router" },
        { "name" : "GOVUK_APP_ROOT", "value" : "/var/apps/router" },

        # these are set by default in the app
        # { "name" : "ROUTER_BACKEND_CONNECT_TIMEOUT", "value" : "1s" },
        # { "name" : "ROUTER_BACKEND_HEADER_TIMEOUT", "value" : "15s" },
        # { "name" : "ROUTER_ERROR_LOG", "value" : "STDERR" },
        # { "name" : "ROUTER_TLS_SKIP_VERIFY", "value" : ""},

        { "name" : "SENTRY_DSN", "value" : "" },
        { "name" : "SENTRY_ENVIRONMENT", "value" : "" },
        { "name" : "ROUTER_PUBADDR", "value" : ":3054" },
        { "name" : "ROUTER_APIADDR", "value" : ":3055" },
        { "name" : "ROUTER_MONGO_URL", "value" : "mongodb://${var.mongodb_host}" },
        { "name" : "ROUTER_MONGO_DB", "value" : "router" },
        { "name" : "DEBUG", "value" : "true" }
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
          "containerPort" : 3054,
          "hostPort" : 3054,
          "protocol" : "tcp"
        },
        {
          "containerPort" : 3055,
          "hostPort" : 3055,
          "protocol" : "tcp"
        }
      ],
      "secrets" : [
        {
          "name" : "SENTRY_DSN",
          "valueFrom" : data.aws_secretsmanager_secret.sentry_dsn.arn
        }
      ]
    }
  ]
}
