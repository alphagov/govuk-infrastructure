module "signon" {
  service_name                     = "signon"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  subnets                          = local.private_subnets
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/app"
  desired_count                    = var.signon_desired_count
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  load_balancers = [{
    target_group_arn = module.signon_public_alb.target_group_arn
    container_name   = "signon"
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

module "signon_public_alb" {
  source = "../../modules/public-load-balancer"

  app_name                  = "signon"
  vpc_id                    = local.vpc_id
  dns_a_record_name         = "signon-ecs"
  public_subnets            = local.public_subnets
  app_domain                = var.public_lb_domain_name # TODO: Change to app_domain
  public_lb_domain_name     = var.public_lb_domain_name
  workspace_suffix          = "govuk" # TODO: Changeme
  service_security_group_id = module.signon.security_group_id
}
