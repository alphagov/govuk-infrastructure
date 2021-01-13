terraform {
  backend "s3" {
    key     = "projects/content-store.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = var.assume_role_arn
  }
}

data "aws_region" "current" {}

data "aws_secretsmanager_secret" "oauth_id" {
  name = "content-store_OAUTH_ID"
}
data "aws_secretsmanager_secret" "oauth_secret" {
  name = "content-store_OAUTH_SECRET"
}
data "aws_secretsmanager_secret" "publishing_api_bearer_token" {
  name = "content-store_PUBLISHING_API_BEARER_TOKEN" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "router_api_bearer_token" {
  name = "content-store_ROUTER_API_BEARER_TOKEN" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "secret_key_base" {
  name = "content-store_SECRET_KEY_BASE" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "SENTRY_DSN"
}

data "terraform_remote_state" "govuk_aws_mongo" {
  backend = "s3"
  config = {
    bucket   = "govuk-terraform-steppingstone-${var.govuk_environment}"
    key      = "${var.govuk_environment == "test" ? "pink" : "blue"}/app-mongo.tfstate"
    region   = data.aws_region.current.name
    role_arn = var.assume_role_arn
  }
}

data "terraform_remote_state" "govuk" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket   = "govuk-terraform-${var.govuk_environment}"
    key      = "projects/govuk.tfstate"
    region   = data.aws_region.current.name
    role_arn = var.assume_role_arn
  }
}

locals {
  app_name = "content-store"

  app_domain                     = data.terraform_remote_state.govuk.outputs.app_domain
  app_domain_internal            = data.terraform_remote_state.govuk.outputs.app_domain_internal
  fargate_execution_iam_role_arn = data.terraform_remote_state.govuk.outputs.fargate_execution_iam_role_arn
  fargate_task_iam_role_arn      = data.terraform_remote_state.govuk.outputs.fargate_task_iam_role_arn
  govuk_website_root             = data.terraform_remote_state.govuk.outputs.govuk_website_root
  log_group                      = data.terraform_remote_state.govuk.outputs.log_group
  mesh_domain                    = data.terraform_remote_state.govuk.outputs.mesh_domain
  mesh_name                      = data.terraform_remote_state.govuk.outputs.mesh_name

  mongodb_host = join(",", [
    data.terraform_remote_state.govuk_aws_mongo.outputs.mongo_1_service_dns_name,
    data.terraform_remote_state.govuk_aws_mongo.outputs.mongo_2_service_dns_name,
    data.terraform_remote_state.govuk_aws_mongo.outputs.mongo_3_service_dns_name,
  ])

  sentry_environment = "${var.govuk_environment}-ecs"
  statsd_host        = "statsd.${local.mesh_domain}" # TODO: Duplicated, move into variable

  environment_variables = {
    DEFAULT_TTL                     = 1800,
    GOVUK_APP_DOMAIN                = local.mesh_domain,
    GOVUK_APP_DOMAIN_EXTERNAL       = local.app_domain,
    GOVUK_APP_NAME                  = "content-store",
    GOVUK_APP_TYPE                  = "rack",
    GOVUK_CONTENT_SCHEMAS_PATH      = "/govuk-content-schemas",
    GOVUK_GROUP                     = "deploy",  # TODO: clean up?
    GOVUK_STATSD_PREFIX             = "fargate", # TODO: use a better prefix?
    GOVUK_STATSD_HOST               = local.statsd_host
    GOVUK_STATSD_PROTOCOL           = "tcp"
    GOVUK_USER                      = "deploy",  # TODO: clean up?
    GOVUK_WEBSITE_ROOT              = local.govuk_website_root,
    PLEK_SERVICE_PUBLISHING_API_URI = "http://publishing-api-web.${local.mesh_domain}",
    PLEK_SERVICE_ROUTER_API_URI     = "http://router-api.${local.mesh_domain}",
    PLEK_SERVICE_RUMMAGER_URI       = "",
    PLEK_SERVICE_SIGNON_URI         = "https://signon-ecs.${local.app_domain}",
    PLEK_SERVICE_SPOTLIGHT_URI      = "",
    PORT                            = 80,
    RAILS_ENV                       = "production",
    SENTRY_ENVIRONMENT              = local.sentry_environment,
    UNICORN_WORKER_PROCESSES        = 12,

    PLEK_SERVICE_PERFORMANCEPLATFORM_BIG_SCREEN_VIEW_URI = "",
  }

  secrets_from_arns = {
    GDS_SSO_OAUTH_ID            = data.aws_secretsmanager_secret.oauth_id.arn,
    GDS_SSO_OAUTH_SECRET        = data.aws_secretsmanager_secret.oauth_secret.arn,
    PUBLISHING_API_BEARER_TOKEN = data.aws_secretsmanager_secret.publishing_api_bearer_token.arn,
    ROUTER_API_BEARER_TOKEN     = data.aws_secretsmanager_secret.router_api_bearer_token.arn,
    SECRET_KEY_BASE             = data.aws_secretsmanager_secret.secret_key_base.arn,
    SENTRY_DSN                  = data.aws_secretsmanager_secret.sentry_dsn.arn,
  }
}
