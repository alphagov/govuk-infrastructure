locals {
  frontend_defaults = {
    cpu    = 512  # TODO parameterize this
    memory = 1024 # TODO parameterize this

    environment_variables = merge(
    local.defaults.environment_variables,
    {
      GOVUK_APP_NAME                  = "frontend",
      GOVUK_CONTENT_SCHEMAS_PATH      = "/govuk-content-schemas",
      PLEK_SERVICE_PUBLISHING_API_URI = local.defaults.publishing_api_uri
      PLEK_SERVICE_SIGNON_URI         = local.defaults.signon_uri
      UNICORN_WORKER_PROCESSES        = 12,
      ASSET_HOST                      = local.defaults.environment_variables.GOVUK_WEBSITE_ROOT,
      PLEK_SERVICE_CONTENT_STORE_URI  = local.defaults.content_store_uri
      PLEK_SERVICE_STATIC_URI         = local.defaults.static_uri
      PLEK_SERVICE_PUBLISHING_API_URI = local.defaults.publishing_api_uri
      PLEK_SERVICE_SIGNON_URI         = local.defaults.signon_uri
      GOVUK_ASSET_ROOT                = local.defaults.asset_root_url
      RAILS_SERVE_STATIC_FILES        = "yes"
      RAILS_SERVE_STATIC_ASSETS       = "yes"
      HEROKU_APP_NAME                 = "frontend"
    }
    )

    secrets_from_arns = merge(
    local.defaults.secrets_from_arns,
    {
      GDS_SSO_OAUTH_ID            = data.aws_secretsmanager_secret.content_store_oauth_id.arn,
      GDS_SSO_OAUTH_SECRET        = data.aws_secretsmanager_secret.content_store_oauth_secret.arn,
      PUBLISHING_API_BEARER_TOKEN = data.aws_secretsmanager_secret.content_store_publishing_api_bearer_token.arn,
      ROUTER_API_BEARER_TOKEN     = data.aws_secretsmanager_secret.content_store_router_api_bearer_token.arn,
      SECRET_KEY_BASE             = data.aws_secretsmanager_secret.content_store_secret_key_base.arn,
    }
    )

    mongodb_host = join(",", [
      data.terraform_remote_state.govuk_aws_mongo.outputs.mongo_1_service_dns_name,
      data.terraform_remote_state.govuk_aws_mongo.outputs.mongo_2_service_dns_name,
      data.terraform_remote_state.govuk_aws_mongo.outputs.mongo_3_service_dns_name,
    ])
  }
}

module "frontend" {
  service_name                     = "frontend"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/app"
  desired_count                    = var.frontend_desired_count
  subnets                          = local.private_subnets
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  load_balancers = [{
    target_group_arn = module.frontend_public_alb.target_group_arn
    container_port   = 80
  }]
  environment_variables = local.frontend_defaults.environment_variables
  secrets_from_arns     = local.frontend_defaults.secrets_from_arns
  log_group             = local.log_group
  aws_region            = data.aws_region.current.name
  cpu                   = local.frontend_defaults.cpu
  memory                = local.frontend_defaults.memory
  task_role_arn         = aws_iam_role.task.arn
  execution_role_arn    = aws_iam_role.execution.arn
}

module "frontend_public_alb" {
  source = "../../modules/public-load-balancer"

  app_name                  = "frontend"
  vpc_id                    = local.vpc_id
  dns_a_record_name         = "frontend"
  public_subnets            = local.public_subnets
  external_app_domain       = var.external_app_domain
  publishing_service_domain = var.publishing_service_domain
  workspace_suffix          = "govuk" # TODO: Changeme
  service_security_group_id = module.frontend.security_group_id
  external_cidrs_list       = var.office_cidrs_list
  health_check_path         = "/"
}

module "draft_frontend" {
  service_name                     = "draft-frontend"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/app"
  desired_count                    = var.draft_frontend_desired_count
  subnets                          = local.private_subnets
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  load_balancers = [{
    target_group_arn = module.draft_frontend_public_alb.target_group_arn
    container_port   = 80
  }]
  environment_variables = local.frontend_defaults.environment_variables
  secrets_from_arns     = local.frontend_defaults.secrets_from_arns
  log_group             = local.log_group
  aws_region            = data.aws_region.current.name
  cpu                   = local.frontend_defaults.cpu
  memory                = local.frontend_defaults.memory
  task_role_arn         = aws_iam_role.task.arn
  execution_role_arn    = aws_iam_role.execution.arn
}

module "draft_frontend_public_alb" {
  source = "../../modules/public-load-balancer"

  app_name                  = "draft-frontend"
  vpc_id                    = local.vpc_id
  dns_a_record_name         = "draft-frontend"
  public_subnets            = local.public_subnets
  external_app_domain       = var.external_app_domain
  publishing_service_domain = var.publishing_service_domain
  workspace_suffix          = "govuk" # TODO: Changeme
  service_security_group_id = module.draft_frontend.security_group_id
  external_cidrs_list       = var.office_cidrs_list
  health_check_path         = "/"
}
