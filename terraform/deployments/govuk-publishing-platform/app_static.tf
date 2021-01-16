module "static" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  private_subnets                  = local.private_subnets
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/apps/static"
  desired_count                    = var.static_desired_count
  public_subnets                   = local.public_subnets
  public_lb_domain_name            = var.public_lb_domain_name
}

module "draft_static" {
  service_name                     = "draft-static"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  private_subnets                  = local.private_subnets
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  execution_role_arn               = aws_iam_role.execution.arn
  source                           = "../../modules/apps/static"
  desired_count                    = var.draft_static_desired_count
  public_subnets                   = local.public_subnets
  public_lb_domain_name            = var.public_lb_domain_name
}

