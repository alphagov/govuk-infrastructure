locals {
  defaults = {
    environment_variables = {
      DEFAULT_TTL               = 1800,
      GOVUK_APP_DOMAIN          = var.mesh_domain,
      GOVUK_APP_DOMAIN_EXTERNAL = var.external_app_domain,
      GOVUK_APP_TYPE            = "rack",
      GOVUK_STATSD_HOST         = "statsd.${var.mesh_domain}"
      GOVUK_STATSD_PROTOCOL     = "tcp"
      GOVUK_WEBSITE_ROOT        = "https://frontend.${var.external_app_domain}", # TODO: Change back to www once router is up
      PORT                      = 80,
      RAILS_ENV                 = "production",
      SENTRY_ENVIRONMENT        = "${var.govuk_environment}-ecs",
    }
    secrets_from_arns = {
      SENTRY_DSN = data.aws_secretsmanager_secret.sentry_dsn.arn,
    }
    asset_host           = "https://frontend.${var.external_app_domain}",
    draft_origin_uri     = "https://draft-frontend.${var.external_app_domain}",
    publishing_api_uri   = "http://publishing-api-web.${var.mesh_domain}",
    router_api_uri       = "http://router-api.${var.mesh_domain}",
    draft_router_api_uri = "http://draft-router-api.${var.mesh_domain}",
    signon_uri           = "https://signon-ecs.${var.external_app_domain}",
    website_root         = "https://frontend.${var.external_app_domain}",
  }
}
