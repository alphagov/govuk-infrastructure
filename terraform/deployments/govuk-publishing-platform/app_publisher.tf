module "publisher_web" {
  service_name                     = "publisher-web"
  cluster_id                       = aws_ecs_cluster.cluster.id
  mesh_name                        = aws_appmesh_mesh.govuk.id
  subnets                          = local.private_subnets
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  source                           = "../../modules/app"
  execution_role_arn               = aws_iam_role.execution.arn
  vpc_id                           = local.vpc_id
  desired_count                    = var.publisher_desired_count
  extra_security_groups            = [local.govuk_management_access_sg_id, aws_security_group.mesh_ecs_service.id]
  load_balancers = [{
    target_group_arn = module.publisher_public_alb.target_group_arn
    container_name   = "publisher-web"
    container_port   = 80
  }]
}

#
# Internet-facing load balancer
#

module "publisher_public_alb" {
  source = "../../modules/public-load-balancer"

  app_name                  = "publisher"
  vpc_id                    = local.vpc_id
  dns_a_record_name         = "publisher"
  public_subnets            = local.public_subnets
  app_domain                = var.public_lb_domain_name # TODO: Change to app_domain
  public_lb_domain_name     = var.public_lb_domain_name
  workspace_suffix          = "govuk" # TODO: Changeme
  service_security_group_id = module.publisher_web.security_group_id
  external_cidrs_list       = var.office_cidrs_list
}

#
# Sidekiq Worker Service
#
module "publisher_worker" {
  service_name                     = "publisher-worker"
  cluster_id                       = aws_ecs_cluster.cluster.id
  mesh_name                        = aws_appmesh_mesh.govuk.id
  subnets                          = local.private_subnets
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  source                           = "../../modules/app"
  execution_role_arn               = aws_iam_role.execution.arn
  vpc_id                           = local.vpc_id
  extra_security_groups            = [module.publisher_web.security_group_id, local.govuk_management_access_sg_id, aws_security_group.mesh_ecs_service.id]
}
