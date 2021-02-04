locals {
  router_defaults = {
    cpu    = 512  # TODO parameterize this
    memory = 1024 # TODO parameterize this

    environment_variables = merge(
      local.defaults.environment_variables,
      {
        GOVUK_APP_NAME                = "router",
        GOVUK_APP_ROOT                = "/var/apps/router",
        ROUTER_APIADDR                = ":3055",
        ROUTER_BACKEND_HEADER_TIMEOUT = "20s",
        ROUTER_PUBADDR                = ":80",
      }
    )

    secrets_from_arns = local.defaults.secrets_from_arns

    mongodb_hosts = "mongodb://${join(",", [
      data.terraform_remote_state.govuk_aws_router_mongo.outputs.router_backend_1_service_dns_name,
      data.terraform_remote_state.govuk_aws_router_mongo.outputs.router_backend_2_service_dns_name,
      data.terraform_remote_state.govuk_aws_router_mongo.outputs.router_backend_3_service_dns_name,
    ])}"
  }
}

module "router" {
  source = "../../modules/app"

  service_name                     = "router"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = local.vpc_id
  subnets                          = local.private_subnets
  desired_count                    = var.router_desired_count
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  custom_container_services = [
    { container_service = "router", port = 80, protocol = "tcp" },
    { container_service = "router-reload", port = 3055, protocol = "tcp" },
  ]
  environment_variables = merge(
    local.router_defaults.environment_variables,
    {
      ROUTER_MONGO_DB  = "router"
      ROUTER_MONGO_URL = "mongodb://${local.router_defaults.mongodb_hosts}/router",
    },
  )
  secrets_from_arns  = local.router_defaults.secrets_from_arns
  log_group          = local.log_group
  aws_region         = data.aws_region.current.name
  cpu                = local.router_defaults.cpu
  memory             = local.router_defaults.memory
  task_role_arn      = aws_iam_role.task.arn
  execution_role_arn = aws_iam_role.execution.arn
}

module "draft_router" {
  source = "../../modules/app"

  service_name                     = "draft-router"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = local.vpc_id
  subnets                          = local.private_subnets
  desired_count                    = var.draft_router_desired_count
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  custom_container_services = [
    { container_service = "draft-router", port = 80, protocol = "tcp" },
    { container_service = "draft-router-reload", port = 3055, protocol = "tcp" },
  ]
  environment_variables = merge(
    local.router_defaults.environment_variables,
    {
      ROUTER_MONGO_DB  = "draft_router"
      ROUTER_MONGO_URL = "mongodb://${local.router_defaults.mongodb_hosts}/draft_router",
    },
  )
  secrets_from_arns  = local.router_defaults.secrets_from_arns
  log_group          = local.log_group
  aws_region         = data.aws_region.current.name
  cpu                = local.router_defaults.cpu
  memory             = local.router_defaults.memory
  task_role_arn      = aws_iam_role.task.arn
  execution_role_arn = aws_iam_role.execution.arn
}
