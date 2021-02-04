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
        REDIS_URL                        = local.defaults.redis_url,
        RAILS_SERVE_STATIC_FILES         = "enabled",
        RAILS_SERVE_STATIC_ASSETS        = "yes",
      }
    )

    secrets_from_arns = local.defaults.secrets_from_arns
  }
}

module "static" {
  source = "../../modules/app"

  service_name                     = "static"
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
      ASSET_HOST          = "https://static-ecs.${var.external_app_domain}", #TODO: fix when router is fully functional
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
    target_group_arn = module.static_public_alb.target_group_arn
    container_port   = 80
  }]
}

module "draft_static" {
  source = "../../modules/app"

  service_name                     = "draft-static"
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
      ASSET_HOST          = "https://draft-static-ecs.${var.external_app_domain}", #TODO: fix when router is fully functional
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
    target_group_arn = module.draft_static_public_alb.target_group_arn
    container_port   = 80
  }]
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
