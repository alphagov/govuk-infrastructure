locals {
  workspace                 = terraform.workspace == "default" ? "ecs" : terraform.workspace #default terraform workspace mapped to ecs
  workspace_external_domain = "${local.workspace}.${var.external_app_domain}"
  workspace_internal_domain = "${local.workspace}.${var.internal_app_domain}"
  mesh_domain               = "mesh.${local.workspace_internal_domain}"
  public_entry_url          = terraform.workspace == "default" ? "https://www.ecs.${var.publishing_service_domain}" : "https://${module.www_origin.fqdn}"
  defaults = {
    environment_variables = {
      DEFAULT_TTL               = 1800,
      GOVUK_APP_DOMAIN          = local.mesh_domain,
      GOVUK_APP_DOMAIN_EXTERNAL = local.workspace_external_domain,
      GOVUK_APP_TYPE            = "rack",
      GOVUK_STATSD_HOST         = "statsd.${local.mesh_domain}"
      GOVUK_STATSD_PROTOCOL     = "tcp"
      GOVUK_WEBSITE_ROOT        = local.public_entry_url
      PORT                      = 80,
      RAILS_ENV                 = "production",
      SENTRY_ENVIRONMENT        = "${var.govuk_environment}-ecsplatform-${local.workspace}",
    }
    secrets_from_arns = {
      # SENTRY_DSN      = data.aws_secretsmanager_secret.sentry_dsn.arn,
      GA_UNIVERSAL_ID = data.aws_secretsmanager_secret.ga_universal_id.arn,
    }
    asset_root_url          = "https://assets.${var.publishing_service_domain}",
    assets_www_origin       = local.public_entry_url,
    assets_draft_origin     = "https://${module.draft_origin.fqdn}"
    content_store_uri       = "http://content-store.${local.mesh_domain}",
    draft_content_store_uri = "http://draft-content-store.${local.mesh_domain}",
    draft_origin_uri        = "https://draft-frontend.${local.workspace_external_domain}",
    draft_static_uri        = "http://draft-static.${local.mesh_domain}"
    publishing_api_uri      = "http://publishing-api-web.${local.mesh_domain}",
    rabbitmq_hosts          = "rabbitmq.${var.internal_app_domain}" # TODO: Make workspace-aware
    router_api_uri          = "http://router-api.${local.mesh_domain}",
    draft_router_api_uri    = "http://draft-router-api.${local.mesh_domain}",
    router_urls             = "router.${local.mesh_domain}:3055",       # TODO(https://trello.com/c/gmzObCBG/95): router-api expects a list of individual instances, so this won't work as-is.
    draft_router_urls       = "draft-router.${local.mesh_domain}:3055", # TODO(https://trello.com/c/gmzObCBG/95): router-api expects a list of individual instances, so this won't work as-is.
    signon_uri              = "https://signon.${local.workspace_external_domain}",
    static_uri              = "http://static.${local.mesh_domain}",
    website_root            = local.public_entry_url,

    virtual_service_backends = [
      module.statsd.virtual_service_name
    ]
  }
}
