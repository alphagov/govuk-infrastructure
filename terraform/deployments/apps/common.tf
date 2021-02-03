locals {
  asset_host                       = local.website_root
  assets_url                       = "https://static-ecs.${var.external_app_domain}"
  draft_assets_url                 = "https://draft-static-ecs.${var.external_app_domain}"
  frontend_assets_url              = "https://frontend.${var.external_app_domain}"
  draft_frontend_assets_url        = "https://draft-frontend.${var.external_app_domain}"
  content_store_url                = "http://content-store.${var.mesh_domain}"
  draft_content_store_url          = "http://draft-content-store.${var.mesh_domain}"
  redis_port                       = 6379
  service_discovery_namespace_name = var.mesh_domain
  sentry_environment               = "${var.govuk_environment}-ecs"
  static_url                       = "http://static.${var.mesh_domain}"
  draft_static_url                 = "http://draft-static.${var.mesh_domain}"
  statsd_host                      = "statsd.${var.mesh_domain}"                   # TODO: Put Statsd in App Mesh
  website_root                     = "https://frontend.${var.external_app_domain}" # TODO: Change back to www once router is up
  router_urls                      = "router.${var.mesh_domain}:3055"              # TODO(https://trello.com/c/gmzObCBG/95): router-api expects a list of individual instances, so this won't work as-is.
  draft_router_urls                = "draft-router.${var.mesh_domain}:3055"        # TODO(https://trello.com/c/gmzObCBG/95): router-api expects a list of individual instances, so this won't work as-is.
}

data "aws_iam_role" "execution" {
  name = "fargate_execution_role"
}

data "aws_iam_role" "task" {
  name = "fargate_task_role"
}
