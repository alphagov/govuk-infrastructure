terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.69"
    }
  }
}

data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "signon_app-SENTRY_DSN"
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
  extra_security_groups            = [var.govuk_management_access_sg_id]
  container_definitions = [
    {
      "name" : "signon",
      "image" : "govuk/signon:deployed-to-production",
      "essential" : true,
      "environment" : [
        { "name" : "GOVUK_APP_NAME", "value" : "signon" },
        { "name" : "GOVUK_APP_ROOT", "value" : "/var/apps/signon" },
        { "name" : "PORT", "value" : "8080" },
        { "name" : "DATABASE_URL", "value" : "${var.signon_db_url}" },
        { "name" : "RAILS_ENV", "value" : "development" },
        { "name" : "TEST_DATABASE_URL", "value" : "${var.signon_test_db_url}" },
        { "name" : "SENTRY_ENVIRONMENT", "value" : "test" }
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
          "containerPort" : 8080,
          "hostPort" : 8080,
          "protocol" : "tcp"
        },
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
