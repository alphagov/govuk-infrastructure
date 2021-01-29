locals {
  defaults = {
    environment_variables = {
      DEFAULT_TTL               = 1800,
      GOVUK_APP_DOMAIN          = var.mesh_domain,
      GOVUK_APP_DOMAIN_EXTERNAL = var.public_lb_domain_name,
      GOVUK_APP_TYPE            = "rack",
      GOVUK_USER                = "deploy", # TODO: is this needed?
      GOVUK_GROUP               = "deploy", # TODO: is this needed?
      GOVUK_STATSD_HOST         = "statsd.${var.mesh_domain}"
      GOVUK_STATSD_PROTOCOL     = "tcp"
      GOVUK_WEBSITE_ROOT        = "https://frontend.${var.public_lb_domain_name}", # TODO: Change back to www once router is up
      PORT                      = 80,
      RAILS_ENV                 = "production",
      SENTRY_ENVIRONMENT        = "${var.govuk_environment}-ecs",
    }
    secrets_from_arns = {
      SENTRY_DSN = data.aws_secretsmanager_secret.sentry_dsn.arn,
    }
    publishing_api_uri   = "http://publishing-api-web.${var.mesh_domain}",
    router_api_uri       = "http://router-api.${var.mesh_domain}",
    draft_router_api_uri = "http://draft-router-api.${var.mesh_domain}",
    signon_uri           = "https://signon-ecs.${var.public_lb_domain_name}",
  }
}
