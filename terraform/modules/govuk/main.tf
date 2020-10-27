terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.69"
    }
  }
}

locals {
  default_image_tag = "deployed-to-${var.govuk_environment}"
}

# TODO: remove the redundant `_service` suffixes; they make it tedious to refer
# to outputs e.g. in security_group_rules.tf.
module "frontend_service" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  task_role_arn                    = aws_iam_role.task.arn
  execution_role_arn               = aws_iam_role.execution.arn
  vpc_id                           = var.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  statsd_host                      = var.statsd_host
  mongodb_host                     = var.mongodb_host
  govuk_website_root               = var.govuk_website_root
  govuk_app_domain_external        = var.govuk_app_domain_external
  source                           = "../../modules/apps/frontend"
}

module "publisher_service" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  task_role_arn                    = aws_iam_role.task.arn
  execution_role_arn               = aws_iam_role.execution.arn
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = var.vpc_id
  private_subnets                  = var.private_subnets
  public_subnets                   = var.public_subnets
  public_lb_domain_name            = var.public_lb_domain_name
  govuk_management_access_sg_id    = var.govuk_management_access_sg_id
  # App environment variables
  asset_host                = var.asset_host
  govuk_app_domain_external = var.govuk_app_domain_external
  govuk_website_root        = var.govuk_website_root
  statsd_host               = var.statsd_host
  redis_host                = var.redis_host
  source                    = "../../modules/apps/publisher"
}

module "content_store_service" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  task_role_arn                    = aws_iam_role.task.arn
  execution_role_arn               = aws_iam_role.execution.arn
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = var.vpc_id
  private_subnets                  = var.private_subnets
  govuk_app_domain_external        = var.govuk_app_domain_external
  govuk_website_root               = var.govuk_website_root
  mongodb_url                      = "mongodb://${var.mongodb_host}/content_store_production"
  statsd_host                      = var.statsd_host
  source                           = "../../modules/apps/content-store"
}

module "draft_content_store_service" {
  service_name                     = "draft-content-store"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  task_role_arn                    = aws_iam_role.task.arn
  execution_role_arn               = aws_iam_role.execution.arn
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = var.vpc_id
  private_subnets                  = var.private_subnets
  govuk_app_domain_external        = var.govuk_app_domain_external
  govuk_website_root               = var.govuk_website_root
  mongodb_url                      = "mongodb://${var.mongodb_host}/draft_content_store_production"
  statsd_host                      = var.statsd_host
  source                           = "../../modules/apps/content-store"
}

module "publishing_api_service" {
  image_tag                        = local.default_image_tag
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  task_role_arn                    = aws_iam_role.task.arn
  execution_role_arn               = aws_iam_role.execution.arn
  vpc_id                           = var.vpc_id
  govuk_app_domain_external        = var.govuk_app_domain_external
  govuk_app_domain_internal        = var.govuk_app_domain_internal
  govuk_website_root               = var.govuk_website_root
  cluster_id                       = aws_ecs_cluster.cluster.id
  statsd_host                      = var.statsd_host
  redis_host                       = var.redis_host
  sentry_environment               = var.sentry_environment
  source                           = "../../modules/apps/publishing-api"
}

module "router_service" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  task_role_arn                    = aws_iam_role.task.arn
  execution_role_arn               = aws_iam_role.execution.arn
  private_subnets                  = var.private_subnets
  vpc_id                           = var.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  router_mongodb_host              = var.router_mongodb_host
  source                           = "../../modules/apps/router"
}
