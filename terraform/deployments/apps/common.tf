locals {
  asset_host                       = local.website_root
  assets_url                       = "https://static-ecs.${var.app_domain}"
  frontend_assets_url              = "https://frontend.${var.app_domain}"
  content_store_url                = "http://content-store.${var.mesh_domain}"
  redis_port                       = 6379
  service_discovery_namespace_name = var.mesh_domain
  sentry_environment               = "${var.govuk_environment}-ecs"
  static_url                       = "http://static.${var.mesh_domain}"
  statsd_host                      = "statsd.${var.mesh_domain}"     # TODO: Put Statsd in App Mesh
  website_root                     = "https://www.${var.app_domain}" # TODO: Is this correct?
  router_urls                      = "router.${var.mesh_domain}:3055"
}

data "aws_iam_role" "execution" {
  name = "fargate_execution_role"
}

data "aws_iam_role" "task" {
  name = "fargate_task_role"
}
