module "content_store" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = local.vpc_id
  private_subnets                  = local.private_subnets
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/apps/content-store"
  desired_count                    = var.content_store_desired_count
}

module "draft_content_store" {
  service_name                     = "draft-content-store"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = local.vpc_id
  private_subnets                  = local.private_subnets
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/apps/content-store"
  desired_count                    = var.draft_content_store_desired_count
}

