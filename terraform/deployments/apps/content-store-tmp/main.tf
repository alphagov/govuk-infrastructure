terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/content-store-tmp.tfstate" # TODO remove -tmp
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

# TODO pass this ARN in from the govuk deployment (via terraform remote state) instead of using a data source
data "aws_iam_role" "execution" {
  name = "fargate_execution_role"
}

# TODO pass this ARN in from the govuk deployment (via terraform remote state) instead of using a data source
data "aws_iam_role" "task" {
  name = "fargate_task_role"
}

locals {
  # --------------------------------------------------------------------------------------------
  # TODO pass all of these locals in from the govuk deployment (e.g. via terraform remote state)
  log_group           = "govuk"
  mesh_name           = "govuk"
  mesh_domain         = "mesh.govuk-internal.digital"
  app_domain          = "test.govuk.digital" # TODO: changed from test.publishing.service.gov.uk for easier testing.
  app_domain_internal = "test.govuk-internal.digital"
  mongodb_host        = join(",", [for i in [1, 2, 3] : "mongo-${i}.${local.app_domain_internal}"])
  sentry_environment  = "test"
  govuk_website_root  = "https://frontend.${local.app_domain}" # TODO: Change back to www once router is up
  statsd_host         = "statsd.${local.mesh_domain}"          # TODO: Put Statsd in App Mesh
  # --------------------------------------------------------------------------------------------

  environment_variables = {
    DEFAULT_TTL                     = 1800,
    GOVUK_APP_DOMAIN                = local.mesh_domain,
    GOVUK_APP_DOMAIN_EXTERNAL       = local.app_domain,
    GOVUK_APP_NAME                  = "content-store",
    GOVUK_APP_TYPE                  = "rack",
    GOVUK_CONTENT_SCHEMAS_PATH      = "/govuk-content-schemas",
    GOVUK_GROUP                     = "deploy",  # TODO: clean up?
    GOVUK_STATSD_PREFIX             = "fargate", # TODO: use a better prefix?
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
    STATSD_PROTOCOL                 = "tcp",
    STATSD_HOST                     = local.statsd_host,
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
