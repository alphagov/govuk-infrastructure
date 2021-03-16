locals {
  mesh_domain = terraform.workspace == "default" ? var.mesh_domain : "mesh-${terraform.workspace}.govuk-internal.digital"
  defaults = {
    environment_variables = {
      DEFAULT_TTL               = 1800,
      GOVUK_APP_DOMAIN          = local.mesh_domain,
      GOVUK_APP_DOMAIN_EXTERNAL = var.external_app_domain,
      GOVUK_APP_TYPE            = "rack",
      GOVUK_STATSD_HOST         = "statsd.${var.mesh_domain}"
      GOVUK_STATSD_PROTOCOL     = "tcp"
      GOVUK_WEBSITE_ROOT        = "https://${module.www_origin.fqdn}",
      PORT                      = 80,
      RAILS_ENV                 = "production",
      SENTRY_ENVIRONMENT        = "${var.govuk_environment}-ecs",
    }
    secrets_from_arns = {
      SENTRY_DSN      = data.aws_secretsmanager_secret.sentry_dsn.arn,
      GA_UNIVERSAL_ID = data.aws_secretsmanager_secret.ga_universal_id.arn,
    }
    asset_host              = "https://frontend.${var.external_app_domain}",
    asset_root_url          = "https://assets.${var.publishing_service_domain}",
    assets_www_origin       = "https://www.ecs.${var.publishing_service_domain}"
    assets_draft_origin     = "https://draft-origin-ecs.${var.external_app_domain}"
    content_store_uri       = "http://content-store.${local.mesh_domain}",
    draft_content_store_uri = "http://draft-content-store.${local.mesh_domain}",
    draft_origin_uri        = "https://draft-frontend.${var.external_app_domain}",
    draft_static_uri        = "http://draft-static.${local.mesh_domain}"
    publishing_api_uri      = "http://publishing-api-web.${local.mesh_domain}",
    rabbitmq_hosts          = "rabbitmq.${var.internal_app_domain}"
    router_api_uri          = "http://router-api.${local.mesh_domain}",
    draft_router_api_uri    = "http://draft-router-api.${local.mesh_domain}",
    router_urls             = "router.${local.mesh_domain}:3055"       # TODO(https://trello.com/c/gmzObCBG/95): router-api expects a list of individual instances, so this won't work as-is.
    draft_router_urls       = "draft-router.${local.mesh_domain}:3055" # TODO(https://trello.com/c/gmzObCBG/95): router-api expects a list of individual instances, so this won't work as-is.
    signon_uri              = "https://signon-ecs.${var.external_app_domain}",
    static_uri              = "http://static.${local.mesh_domain}"
    website_root            = "https://${module.www_origin.fqdn}",

    virtual_service_backends = [
      module.statsd.virtual_service_name
    ]
  }
}
