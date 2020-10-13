terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.69"
    }
  }
}

data "aws_secretsmanager_secret" "asset_manager_bearer_token" {
  name = "publisher_app-ASSET_MANAGER_BEARER_TOKEN"
}
data "aws_secretsmanager_secret" "fact_check_password" {
  name = "publisher_app-FACT_CHECK_PASSWORD"
}
data "aws_secretsmanager_secret" "fact_check_reply_to_address" {
  name = "publisher_app-FACT_CHECK_REPLY_TO_ADDRESS"
}
data "aws_secretsmanager_secret" "fact_check_reply_to_id" {
  name = "publisher_app-FACT_CHECK_REPLY_TO_ID"
}
data "aws_secretsmanager_secret" "govuk_notify_api_key" {
  name = "publisher_app-GOVUK_NOTIFY_API_KEY"
}
data "aws_secretsmanager_secret" "govuk_notify_template_id" {
  name = "publisher_app-GOVUK_NOTIFY_TEMPLATE_ID" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "jwt_auth_secret" {
  name = "publisher_app-JWT_AUTH_SECRET"
}
data "aws_secretsmanager_secret" "link_checker_api_bearer_token" {
  name = "publisher_app-LINK_CHECKER_API_BEARER_TOKEN"
}
data "aws_secretsmanager_secret" "link_checker_api_secret_token" {
  name = "publisher_app-LINK_CHECKER_API_SECRET_TOKEN"
}
data "aws_secretsmanager_secret" "mongodb_uri" {
  name = "publisher_app-MONGODB_URI"
}
data "aws_secretsmanager_secret" "oauth_id" {
  name = "publisher_app-OAUTH_ID"
}
data "aws_secretsmanager_secret" "oauth_secret" {
  name = "publisher_app-OAUTH_SECRET"
}
data "aws_secretsmanager_secret" "publishing_api_bearer_token" {
  name = "publisher_app-PUBLISHING_API_BEARER_TOKEN" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "secret_key_base" {
  name = "publisher_app-SECRET_KEY_BASE" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "publisher_app-SENTRY_DSN"
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
      # TODO: factor out all the remaining hardcoded values (see ../content-store for an example where this has been done)
      "name" : "publisher",
      "image" : "govuk/publisher:serve-assets-in-prod", # TODO: use deployed-to-production label or similar.
      "essential" : true,
      "environment" : [
        { "name" : "ASSET_HOST", "value" : var.asset_host },
        { "name" : "APPMESH_VIRTUAL_NODE_NAME", "value" : "mesh/${var.mesh_name}/virtualNode/${var.service_name}" },
        { "name" : "BASIC_AUTH_USERNAME", "value" : "gds" },
        { "name" : "EMAIL_GROUP_BUSINESS", "value" : "test-address@digital.cabinet-office.gov.uk" },
        { "name" : "EMAIL_GROUP_CITIZEN", "value" : "test-address@digital.cabinet-office.gov.uk" },
        { "name" : "EMAIL_GROUP_DEV", "value" : "test-address@digital.cabinet-office.gov.uk" },
        { "name" : "EMAIL_GROUP_FORCE_PUBLISH_ALERTS", "value" : "test-address@digital.cabinet-office.gov.uk" },
        { "name" : "FACT_CHECK_SUBJECT_PREFIX", "value" : "dev" },
        { "name" : "FACT_CHECK_USERNAME", "value" : "govuk-fact-check-test@digital.cabinet-office.gov.uk" },
        { "name" : "GOVUK_APP_DOMAIN", "value" : var.service_discovery_namespace_name },
        { "name" : "GOVUK_APP_DOMAIN_EXTERNAL", "value" : var.govuk_app_domain_external },
        { "name" : "GOVUK_APP_NAME", "value" : "publisher" },
        { "name" : "GOVUK_APP_TYPE", "value" : "rack" },
        { "name" : "GOVUK_STATSD_PREFIX", "value" : "fargate" },
        # TODO: how does GOVUK_ASSET_ROOT relate to ASSET_HOST? Is one a function of the other? Are they both really in use? Is GOVUK_ASSET_ROOT always just "https://${ASSET_HOST}"?
        { "name" : "GOVUK_ASSET_ROOT", "value" : "https://assets.test.publishing.service.gov.uk" },
        { "name" : "GOVUK_GROUP", "value" : "deploy" },
        { "name" : "GOVUK_USER", "value" : "deploy" },
        { "name" : "GOVUK_WEBSITE_ROOT", "value" : var.govuk_website_root },
        { "name" : "PLEK_SERVICE_CONTENT_STORE_URI", "value" : "https://www.gov.uk/api" }, # TODO: looks suspicious
        { "name" : "PLEK_SERVICE_PUBLISHING_API_URI", "value" : "http://publishing-api.${var.service_discovery_namespace_name}" },
        { "name" : "PLEK_SERVICE_STATIC_URI", "value" : "https://assets.test.publishing.service.gov.uk" },
        { "name" : "RAILS_ENV", "value" : "production" },
        { "name" : "RAILS_SERVE_STATIC_FILES", "value" : "true" }, # TODO: temporary hack?
        # TODO: we shouldn't be specifying both REDIS_{HOST,PORT} *and* REDIS_URL.
        { "name" : "REDIS_HOST", "value" : var.redis_host },
        { "name" : "REDIS_PORT", "value" : tostring(var.redis_port) },
        { "name" : "REDIS_URL", "value" : "redis://${var.redis_host}:${var.redis_port}" },
        { "name" : "STATSD_PROTOCOL", "value" : "tcp" },
        { "name" : "STATSD_HOST", "value" : var.statsd_host },
        { "name" : "WEBSITE_ROOT", "value" : var.govuk_website_root }
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
          "awslogs-region" : "eu-west-1", # TODO: hardcoded region
          "awslogs-stream-prefix" : "awslogs-publisher"
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
          "name" : "ASSET_MANAGER_BEARER_TOKEN",
          "valueFrom" : data.aws_secretsmanager_secret.asset_manager_bearer_token.arn
        },
        {
          "name" : "FACT_CHECK_PASSWORD",
          "valueFrom" : data.aws_secretsmanager_secret.fact_check_password.arn
        },
        {
          "name" : "FACT_CHECK_REPLY_TO_ADDRESS",
          "valueFrom" : data.aws_secretsmanager_secret.fact_check_reply_to_address.arn
        },
        {
          "name" : "FACT_CHECK_REPLY_TO_ID",
          "valueFrom" : data.aws_secretsmanager_secret.fact_check_reply_to_id.arn
        },
        {
          "name" : "GOVUK_NOTIFY_API_KEY",
          "valueFrom" : data.aws_secretsmanager_secret.govuk_notify_api_key.arn
        },
        {
          "name" : "GOVUK_NOTIFY_TEMPLATE_ID",
          "valueFrom" : data.aws_secretsmanager_secret.govuk_notify_template_id.arn
        },
        {
          "name" : "JWT_AUTH_SECRET",
          "valueFrom" : data.aws_secretsmanager_secret.jwt_auth_secret.arn
        },
        {
          "name" : "LINK_CHECKER_API_BEARER_TOKEN",
          "valueFrom" : data.aws_secretsmanager_secret.link_checker_api_bearer_token.arn
        },
        {
          "name" : "LINK_CHECKER_API_SECRET_TOKEN",
          "valueFrom" : data.aws_secretsmanager_secret.link_checker_api_secret_token.arn
        },
        {
          "name" : "MONGODB_URI",
          "valueFrom" : data.aws_secretsmanager_secret.mongodb_uri.arn
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
          "name" : "PUBLISHING_API_BEARER_TOKEN",
          "valueFrom" : data.aws_secretsmanager_secret.publishing_api_bearer_token.arn
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

#
# Internet-facing load balancer
#

# TODO: use a single, ACM-managed cert with both domains on. There is already
# such a cert in integration/staging/prod (but it needs defining in Terraform).
data "aws_acm_certificate" "public_lb_default" {
  domain   = "*.test.govuk.digital"
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "public_lb_alternate" {
  domain   = "*.test.publishing.service.gov.uk"
  statuses = ["ISSUED"]
}

resource "aws_lb" "public" {
  name               = "fargate-public-${var.service_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb.id]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "public" {
  name        = "${var.service_name}-public"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/healthcheck"
  }

  depends_on = [aws_lb.public]
}

resource "aws_lb_listener" "public" {
  load_balancer_arn = aws_lb.public.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.public_lb_default.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public.arn
  }
}

resource "aws_lb_listener_certificate" "publishing_service" {
  listener_arn    = aws_lb_listener.public.arn
  certificate_arn = data.aws_acm_certificate.public_lb_alternate.arn
}

resource "aws_security_group" "public_alb" {
  name        = "fargate_${var.service_name}_public_alb"
  vpc_id      = var.vpc_id
  description = "${var.service_name} Internet-facing ALB"
}

data "aws_route53_zone" "public" {
  name = var.public_lb_domain_name
}

resource "aws_route53_record" "public_alb" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = var.service_name
  type    = "A"

  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }
}
