module "publishing_api" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/apps/publishing-api"
  desired_count                    = var.publishing_api_desired_count
}

