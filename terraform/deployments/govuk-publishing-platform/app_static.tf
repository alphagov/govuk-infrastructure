locals {
  static_defaults = {
    cpu    = 512  # TODO parameterize this
    memory = 1024 # TODO parameterize this

    environment_variables = merge(
      local.defaults.environment_variables,
      {
        GOVUK_APP_NAME                   = "static",
        GOVUK_APP_ROOT                   = "/var/apps/static",
        PLEK_SERVICE_ACCOUNT_MANAGER_URI = "",
        REDIS_URL                        = module.shared_redis_cluster.uri,
        RAILS_SERVE_STATIC_FILES         = "enabled",
        RAILS_SERVE_STATIC_ASSETS        = "yes",
      }
    )

    secrets_from_arns = local.defaults.secrets_from_arns
  }
}

module "static" {
  source = "../../modules/app"

  image_name                       = "static"
  service_name                     = "static"
  backend_virtual_service_names    = [] # Static doesn't use any other services
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = local.vpc_id
  subnets                          = local.private_subnets
  desired_count                    = var.static_desired_count
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  environment_variables = merge(
    local.static_defaults.environment_variables,
    {
      ASSET_HOST          = local.defaults.assets_www_origin,
      GOVUK_STATSD_PREFIX = "govuk-ecs.app.static"
    },
  )
  secrets_from_arns = merge(
    local.static_defaults.secrets_from_arns,
    {
      PUBLISHING_API_BEARER = data.aws_secretsmanager_secret.static_publishing_api_bearer_token.arn,
      SECRET_KEY_BASE       = data.aws_secretsmanager_secret.static_secret_key_base.arn,
    },
  )
  log_group          = local.log_group
  aws_region         = data.aws_region.current.name
  cpu                = local.static_defaults.cpu
  memory             = local.static_defaults.memory
  task_role_arn      = aws_iam_role.task.arn
  execution_role_arn = aws_iam_role.execution.arn
  load_balancers = [{
    target_group_arn = module.www_origin.static_target_group_arn
    container_port   = 80
  }]
}

module "draft_static" {
  source = "../../modules/app"

  image_name                       = "static"
  service_name                     = "draft-static"
  backend_virtual_service_names    = [] # Static doesn't use any other services
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = local.vpc_id
  subnets                          = local.private_subnets
  desired_count                    = var.draft_static_desired_count
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  environment_variables = merge(
    local.static_defaults.environment_variables,
    {
      ASSET_HOST          = local.defaults.assets_draft_origin,
      GOVUK_STATSD_PREFIX = "govuk-ecs.app.draft-static"
    },
  )
  secrets_from_arns = merge(
    local.static_defaults.secrets_from_arns,
    {
      PUBLISHING_API_BEARER = data.aws_secretsmanager_secret.draft_static_publishing_api_bearer_token.arn,
      SECRET_KEY_BASE       = data.aws_secretsmanager_secret.draft_static_secret_key_base.arn,
    },
  )
  log_group          = local.log_group
  aws_region         = data.aws_region.current.name
  cpu                = local.static_defaults.cpu
  memory             = local.static_defaults.memory
  task_role_arn      = aws_iam_role.task.arn
  execution_role_arn = aws_iam_role.execution.arn
  load_balancers = [{
    target_group_arn = module.draft_origin.static_target_group_arn
    container_port   = 80
  }]
}
