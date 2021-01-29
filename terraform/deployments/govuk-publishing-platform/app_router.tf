module "router" {
  service_name                     = "router"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  subnets                          = local.private_subnets
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/app"
  desired_count                    = var.router_desired_count
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  custom_container_services = [
    { container_service = "router", port = 80, protocol = "tcp" },
    { container_service = "router-reload", port = 3055, protocol = "tcp" },
  ]
  environment_variables = {} # TODO
  secrets_from_arns     = {} # TODO
  log_group             = local.log_group
  aws_region            = data.aws_region.current.name
  cpu                   = 512
  memory                = 1024
  task_role_arn         = aws_iam_role.task.arn
  execution_role_arn    = aws_iam_role.execution.arn
}

module "draft_router" {
  service_name                     = "draft-router"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  subnets                          = local.private_subnets
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/app"
  desired_count                    = var.draft_router_desired_count
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  custom_container_services = [
    { container_service = "draft-router", port = 80, protocol = "tcp" },
    { container_service = "draft-router-reload", port = 3055, protocol = "tcp" },
  ]
  environment_variables = {} # TODO
  secrets_from_arns     = {} # TODO
  log_group             = local.log_group
  aws_region            = data.aws_region.current.name
  cpu                   = 512
  memory                = 1024
  task_role_arn         = aws_iam_role.task.arn
  execution_role_arn    = aws_iam_role.execution.arn
}
