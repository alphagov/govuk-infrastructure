module "publisher" {
  cluster_id                       = aws_ecs_cluster.cluster.id
  govuk_management_access_sg_id    = local.govuk_management_access_sg_id
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  private_subnets                  = local.private_subnets
  public_subnets                   = local.public_subnets
  public_lb_domain_name            = var.public_lb_domain_name
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  source                           = "../../modules/apps/publisher"
  execution_role_arn               = aws_iam_role.execution.arn
  vpc_id                           = local.vpc_id
  desired_count                    = var.publisher_desired_count
}

