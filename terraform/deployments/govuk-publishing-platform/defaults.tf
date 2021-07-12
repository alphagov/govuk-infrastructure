locals {
  workspace                 = terraform.workspace == "default" ? "ecs" : terraform.workspace #default terraform workspace mapped to ecs
  is_default_workspace      = terraform.workspace == "default" ? true : false
  workspace_external_domain = "${local.workspace}.${var.external_app_domain}"
  workspace_internal_domain = "${local.workspace}.${var.internal_app_domain}"
  mesh_domain               = "mesh.${local.workspace_internal_domain}"
  # public_domain             = local.is_default_workspace ? var.publishing_service_domain : local.workspace_external_domain
  public_entry_url = local.is_default_workspace && var.enable_cdn ? "https://www.${local.workspace_external_domain}" : "https://${module.www_frontends_origin.fqdn}"
  defaults = {
    environment_variables = {
      DEFAULT_TTL               = 1800,
      GOVUK_APP_DOMAIN          = local.mesh_domain,
      GOVUK_APP_DOMAIN_EXTERNAL = local.workspace_external_domain,
      GOVUK_APP_TYPE            = "rack",
      GOVUK_ENVIRONMENT         = var.govuk_environment
      GOVUK_ENVIRONMENT_NAME    = var.govuk_environment # For setting environment label in apps - see https://github.com/alphagov/govuk-puppet/commit/5fc81d2e5eace5d36358aa3f5b6d6c84a982ea9c
      GOVUK_STATSD_HOST         = "statsd.${local.mesh_domain}"
      GOVUK_STATSD_PROTOCOL     = "tcp"
      GOVUK_WEBSITE_ROOT        = local.public_entry_url
      GOVUK_WORKSPACE           = local.workspace
      PORT                      = 80,
      RAILS_ENV                 = "production",
      SENTRY_ENVIRONMENT        = "${var.govuk_environment}-ecsplatform-${local.workspace}",
    }
    secrets_from_arns = {
      # SENTRY_DSN      = data.aws_secretsmanager_secret.sentry_dsn.arn,
      GA_UNIVERSAL_ID = data.aws_secretsmanager_secret.ga_universal_id.arn,
    }
    asset_root_url                = "https://assets.${var.publishing_service_domain}",
    assets_www_frontends_origin   = local.public_entry_url,
    assets_draft_frontends_origin = "https://${module.draft_frontends_origin.fqdn}"
    content_store_uri             = "http://content-store.${local.mesh_domain}",
    draft_content_store_uri       = "http://draft-content-store.${local.mesh_domain}",
    draft_static_uri              = "http://draft-static.${local.mesh_domain}"
    publishing_api_uri            = "http://publishing-api-web.${local.mesh_domain}",
    rabbitmq_hosts                = "rabbitmq.${var.internal_app_domain}" # TODO: Make workspace-aware
    router_api_uri                = "http://router-api.${local.mesh_domain}",
    draft_router_api_uri          = "http://draft-router-api.${local.mesh_domain}",
    signon_uri                    = "https://signon.${local.workspace_external_domain}",
    static_uri                    = "http://static.${local.mesh_domain}",
    website_root                  = local.public_entry_url,
    draft_origin_uri              = "https://draft-origin.${local.workspace_external_domain}",

    virtual_service_backends = [
      module.statsd.virtual_service_name
    ]
    splunk_url_secret_arn   = data.aws_secretsmanager_secret.splunk_url.arn
    splunk_token_secret_arn = data.aws_secretsmanager_secret.splunk_token.arn
    splunk_index            = "govuk_replatforming"
    splunk_sourcetype       = "syslog"
  }
}
