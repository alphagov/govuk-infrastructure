module "content_store" {
  service_name                     = "content-store"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = local.vpc_id
  subnets                          = local.private_subnets
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/app"
  desired_count                    = var.content_store_desired_count
  extra_security_groups = [
    local.govuk_management_access_security_group,
    aws_security_group.mesh_ecs_service.id
  ]
}

module "draft_content_store" {
  service_name                     = "draft-content-store"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = local.vpc_id
  subnets                          = local.private_subnets
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/app"
  desired_count                    = var.draft_content_store_desired_count
  extra_security_groups = [
    local.govuk_management_access_security_group,
    aws_security_group.mesh_ecs_service.id
  ]
}
