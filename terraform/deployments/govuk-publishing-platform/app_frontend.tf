module "frontend" {
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/apps/frontend"
  execution_role_arn               = aws_iam_role.execution.arn
  desired_count                    = var.frontend_desired_count
  public_subnets                   = local.public_subnets
  public_lb_domain_name            = var.public_lb_domain_name
  office_cidrs_list                = var.office_cidrs_list
}

module "draft_frontend" {
  service_name                     = "draft-frontend"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  mesh_service_sg_id               = aws_security_group.mesh_ecs_service.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/apps/frontend"
  execution_role_arn               = aws_iam_role.execution.arn
  desired_count                    = var.draft_frontend_desired_count
  public_subnets                   = local.public_subnets
  public_lb_domain_name            = var.public_lb_domain_name
  office_cidrs_list                = var.office_cidrs_list
}

