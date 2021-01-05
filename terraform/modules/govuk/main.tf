terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

# TODO: remove the redundant `_service` suffixes; they make it tedious to refer
# to outputs e.g. in security_group_rules.tf.
module "frontend_service" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = var.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/apps/frontend"
  execution_role_arn               = aws_iam_role.execution.arn
  desired_count                    = var.frontend_desired_count
  public_subnets                   = var.public_subnets
  public_lb_domain_name            = var.public_lb_domain_name
}

module "draft_frontend_service" {
  service_name                     = "draft-frontend"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = var.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/apps/frontend"
  execution_role_arn               = aws_iam_role.execution.arn
  desired_count                    = var.draft_frontend_desired_count
  public_subnets                   = var.public_subnets
  public_lb_domain_name            = var.public_lb_domain_name
}

module "publisher_service" {
  cluster_id                       = aws_ecs_cluster.cluster.id
  govuk_management_access_sg_id    = var.govuk_management_access_sg_id
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  private_subnets                  = var.private_subnets
  public_subnets                   = var.public_subnets
  public_lb_domain_name            = var.public_lb_domain_name
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  source                           = "../../modules/apps/publisher"
  execution_role_arn               = aws_iam_role.execution.arn
  vpc_id                           = var.vpc_id
  desired_count                    = var.publisher_desired_count
}

module "content_store_service" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = var.vpc_id
  private_subnets                  = var.private_subnets
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/apps/content-store"
  desired_count                    = var.content_store_desired_count
}

module "draft_content_store_service" {
  service_name                     = "draft-content-store"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = var.vpc_id
  private_subnets                  = var.private_subnets
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/apps/content-store"
  desired_count                    = var.draft_content_store_desired_count
}

module "publishing_api_service" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = var.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/apps/publishing-api"
  desired_count                    = var.publishing_api_desired_count
}

module "router_service" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  private_subnets                  = var.private_subnets
  vpc_id                           = var.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/apps/router"
  desired_count                    = var.router_desired_count
}

module "draft_router_service" {
  service_name                     = "draft-router"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  private_subnets                  = var.private_subnets
  vpc_id                           = var.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/apps/router"
  desired_count                    = var.draft_router_desired_count
}

module "router_api_service" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  private_subnets                  = var.private_subnets
  vpc_id                           = var.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/apps/router-api"
  desired_count                    = var.router_api_desired_count
}

module "draft_router_api_service" {
  service_name                     = "draft-router-api"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  private_subnets                  = var.private_subnets
  vpc_id                           = var.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/apps/router-api"
  desired_count                    = var.draft_router_api_desired_count
}

module "static_service" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  private_subnets                  = var.private_subnets
  vpc_id                           = var.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/apps/static"
  desired_count                    = var.static_desired_count
  public_subnets                   = var.public_subnets
  public_lb_domain_name            = var.public_lb_domain_name
}

module "draft_static_service" {
  service_name                     = "draft-static"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  private_subnets                  = var.private_subnets
  vpc_id                           = var.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/apps/static"
  desired_count                    = var.draft_static_desired_count
  public_subnets                   = var.public_subnets
  public_lb_domain_name            = var.public_lb_domain_name
}

module "signon_service" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  execution_role_arn               = aws_iam_role.execution.arn
  private_subnets                  = var.private_subnets
  vpc_id                           = var.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/apps/signon"
  desired_count                    = var.signon_desired_count
  public_lb_domain_name            = var.public_lb_domain_name
  public_subnets                   = var.public_subnets
}

module "shared_redis_cluster" {
  source               = "../../modules/redis"
  vpc_id               = var.vpc_id
  internal_domain_name = var.internal_domain_name
  subnet_ids           = var.redis_subnets
}

module "statsd" {
  cluster_id                       = aws_ecs_cluster.cluster.id
  execution_role_arn               = aws_iam_role.execution.arn
  internal_domain_name             = var.internal_domain_name
  govuk_management_access_sg_id    = var.govuk_management_access_sg_id
  mesh_name                        = var.mesh_name
  private_subnets                  = var.private_subnets
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  source                           = "../../modules/statsd"
  task_role_arn                    = aws_iam_role.task.arn
  vpc_id                           = var.vpc_id
}
