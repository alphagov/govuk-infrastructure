module "publishing_api_web" {
  service_name                     = "publishing-api-web"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/app"
  desired_count                    = var.publishing_api_desired_count
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  subnets                          = local.private_subnets
  environment_variables            = {} # TODO
  secrets_from_arns                = {} # TODO
  log_group                        = local.log_group
  aws_region                       = data.aws_region.current.name
  cpu                              = 512
  memory                           = 1024
  task_role_arn                    = aws_iam_role.task.arn
  execution_role_arn               = aws_iam_role.execution.arn
}

module "publishing_api_worker" {
  service_name                     = "publishing-api-worker"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/app"
  desired_count                    = var.publishing_api_desired_count
  extra_security_groups            = [module.publishing_api_web.security_group_id, local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  subnets                          = local.private_subnets
  environment_variables            = {} # TODO
  secrets_from_arns                = {} # TODO
  log_group                        = local.log_group
  aws_region                       = data.aws_region.current.name
  cpu                              = 512
  memory                           = 1024
  task_role_arn                    = aws_iam_role.task.arn
  execution_role_arn               = aws_iam_role.execution.arn
}
