locals {
  app_name = "frontend"
}

data "aws_region" "current" {}

data "aws_secretsmanager_secret" "secret_key_base" {
  name = "frontend_app-SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "publishing_api_bearer_token" {
  name = "frontend_app_PUBLISHING_API_BEARER_TOKEN" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "SENTRY_DSN"
}

module "task_definition_cli_input_json" {
  source             = "../../task-definition-cli-input-json"
  aws_region         = data.aws_region.current.name
  mesh_name          = var.mesh_name
  service_name       = var.service_name
  cpu                = 1024
  memory             = 2048
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
  log_group          = var.log_group

  environment_variables = {
    RAILS_ENV                       = "production",
    ASSET_HOST                      = var.assets_url,
    GOVUK_APP_DOMAIN                = var.service_discovery_namespace_name,
    GOVUK_APP_DOMAIN_EXTERNAL       = var.govuk_app_domain_external,
    GOVUK_STATSD_HOST               = var.statsd_host,
    GOVUK_STATSD_PREFIX             = "govuk.app.${local.app_name}.ecs",
    GOVUK_STATSD_PROTOCOL           = "tcp",
    GOVUK_WEBSITE_ROOT              = var.govuk_website_root,
    WEBSITE_ROOT                    = var.govuk_website_root,
    PORT                            = "80",
    PLEK_SERVICE_CONTENT_STORE_URI  = var.content_store_url,
    PLEK_SERVICE_STATIC_URI         = var.static_url,
    PLEK_SERVICE_PUBLISHING_API_URI = "http://publishing-api-web.${var.service_discovery_namespace_name}",
    PLEK_SERVICE_SIGNON_URI         = "https://signon-ecs.${var.govuk_app_domain_external}",
    GOVUK_ASSET_ROOT                = var.assets_url,
    SENTRY_ENVIRONMENT              = var.sentry_environment,
    # TODO: Setting RAILS_SERVE_STATIC_FILES, RAILS_SERVE_STATIC_ASSETS and HEROKU_APP_NAME are temporary workarounds for serving static assets.
    # Remove them once we have a production solution for assets.
    RAILS_SERVE_STATIC_FILES  = "yes",
    RAILS_SERVE_STATIC_ASSETS = "yes",
    HEROKU_APP_NAME           = var.service_name,
  }

  secrets_from_arns = {
    "SECRET_KEY_BASE"             = data.aws_secretsmanager_secret.secret_key_base.arn,
    "SENTRY_DSN"                  = data.aws_secretsmanager_secret.sentry_dsn.arn,
    "PUBLISHING_API_BEARER_TOKEN" = data.aws_secretsmanager_secret.publishing_api_bearer_token.arn,
  }
}
