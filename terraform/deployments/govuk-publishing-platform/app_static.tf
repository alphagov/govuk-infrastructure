module "static" {
  service_name                     = "static"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  subnets                          = local.private_subnets
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/app"
  desired_count                    = var.static_desired_count
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  load_balancers = [{
    target_group_arn = module.static_public_alb.target_group_arn
    container_name   = "static"
    container_port   = 80
  }]
  environment_variables = {} # TODO
  secrets_from_arns     = {} # TODO
  log_group             = local.log_group
  aws_region            = data.aws_region.current.name
  cpu                   = 512
  memory                = 1024
  task_role_arn         = aws_iam_role.task.arn
  execution_role_arn    = aws_iam_role.execution.arn
}

module "draft_static" {
  service_name                     = "draft-static"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  subnets                          = local.private_subnets
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/app"
  desired_count                    = var.draft_static_desired_count
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  load_balancers = [{
    target_group_arn = module.draft_static_public_alb.target_group_arn
    container_name   = "draft-static"
    container_port   = 80
  }]
  environment_variables = {} # TODO
  secrets_from_arns     = {} # TODO
  log_group             = local.log_group
  aws_region            = data.aws_region.current.name
  cpu                   = 512
  memory                = 1024
  task_role_arn         = aws_iam_role.task.arn
  execution_role_arn    = aws_iam_role.execution.arn
}

#
# Internet-facing load balancer
#

module "static_public_alb" {
  source = "../../modules/public-load-balancer"

  app_name                  = "static"
  vpc_id                    = local.vpc_id
  dns_a_record_name         = "static-ecs"
  public_subnets            = local.public_subnets
  external_app_domain       = var.external_app_domain
  publishing_service_domain = var.publishing_service_domain
  workspace_suffix          = "govuk" # TODO: Changeme
  service_security_group_id = module.static.security_group_id
  external_cidrs_list       = var.office_cidrs_list
  health_check_path         = "/templates/wrapper.html.erb" # TODO: create a proper healthcheck endpoint in static
}

module "draft_static_public_alb" {
  source = "../../modules/public-load-balancer"

  app_name                  = "draft-static"
  vpc_id                    = local.vpc_id
  dns_a_record_name         = "draft-static-ecs"
  public_subnets            = local.public_subnets
  external_app_domain       = var.external_app_domain
  publishing_service_domain = var.publishing_service_domain
  workspace_suffix          = "govuk" # TODO: Changeme
  service_security_group_id = module.draft_static.security_group_id
  external_cidrs_list       = var.office_cidrs_list
  health_check_path         = "/templates/wrapper.html.erb" # TODO: create a proper healthcheck endpoint in static
}
