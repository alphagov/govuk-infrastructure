locals {
  frontend_defaults = {
    cpu    = 1024 # TODO parameterize this
    memory = 2048 # TODO parameterize this

    backend_services = flatten([
      local.defaults.virtual_service_backends,
      module.static.virtual_service_name,
      module.signon.virtual_service_name,
    ])

    environment_variables = merge(
      local.defaults.environment_variables,
      {
        GOVUK_APP_NAME                  = "frontend",
        GOVUK_CONTENT_SCHEMAS_PATH      = "/govuk-content-schemas",
        PLEK_SERVICE_PUBLISHING_API_URI = local.defaults.publishing_api_uri
        PLEK_SERVICE_SIGNON_URI         = local.defaults.signon_uri
        UNICORN_WORKER_PROCESSES        = 12,
        ASSET_HOST                      = local.defaults.assets_www_frontends_origin,
        PLEK_SERVICE_CONTENT_STORE_URI  = local.defaults.content_store_uri
        PLEK_SERVICE_STATIC_URI         = local.defaults.static_uri
        GOVUK_ASSET_ROOT                = local.defaults.asset_root_url
      }
    )

    secrets_from_arns = merge(
      local.defaults.secrets_from_arns,
      {
        # TODO Should frontend and draft frontend share a bearer token for publishing api?
        PUBLISHING_API_BEARER_TOKEN = module.frontend_to_publishing_api_bearer_token.secret_arn
        SECRET_KEY_BASE             = data.aws_secretsmanager_secret.frontend_secret_key_base.arn,
        SENTRY_DSN                  = data.aws_secretsmanager_secret.sentry_dsn.arn,
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
  registry     = var.registry
  image_name   = "frontend"
  service_name = "frontend"
  mesh_name    = aws_appmesh_mesh.govuk.id
  backend_virtual_service_names = flatten([
    local.frontend_defaults.backend_services,
    module.content_store.virtual_service_name,
  ])
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/app"
  desired_count                    = var.frontend_desired_count
  subnets                          = local.private_subnets
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  environment_variables            = local.frontend_defaults.environment_variables
  secrets_from_arns                = local.frontend_defaults.secrets_from_arns
  splunk_url_secret_arn            = local.defaults.splunk_url_secret_arn
  splunk_token_secret_arn          = local.defaults.splunk_token_secret_arn
  splunk_index                     = local.defaults.splunk_index
  splunk_sourcetype                = local.defaults.splunk_sourcetype
  aws_region                       = data.aws_region.current.name
  cpu                              = local.frontend_defaults.cpu
  memory                           = local.frontend_defaults.memory
  task_role_arn                    = aws_iam_role.task.arn
  execution_role_arn               = aws_iam_role.execution.arn
  additional_tags                  = local.additional_tags
  environment                      = var.govuk_environment
  workspace                        = local.workspace
}

module "draft_frontend" {
  registry     = var.registry
  image_name   = "frontend"
  service_name = "draft-frontend"
  mesh_name    = aws_appmesh_mesh.govuk.id
  backend_virtual_service_names = flatten([
    local.frontend_defaults.backend_services,
    module.draft_content_store.virtual_service_name,
  ])
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/app"
  desired_count                    = var.draft_frontend_desired_count
  subnets                          = local.private_subnets
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  environment_variables = merge(
    local.frontend_defaults.environment_variables,
    {
      ASSET_HOST                     = local.defaults.assets_draft_frontends_origin,
      PLEK_SERVICE_CONTENT_STORE_URI = local.defaults.draft_content_store_uri,
      PLEK_SERVICE_STATIC_URI        = local.defaults.draft_static_uri
    }
  )
  secrets_from_arns       = local.frontend_defaults.secrets_from_arns
  splunk_url_secret_arn   = local.defaults.splunk_url_secret_arn
  splunk_token_secret_arn = local.defaults.splunk_token_secret_arn
  splunk_index            = local.defaults.splunk_index
  splunk_sourcetype       = local.defaults.splunk_sourcetype
  aws_region              = data.aws_region.current.name
  cpu                     = local.frontend_defaults.cpu
  memory                  = local.frontend_defaults.memory
  task_role_arn           = aws_iam_role.task.arn
  execution_role_arn      = aws_iam_role.execution.arn
  additional_tags         = local.additional_tags
  environment             = var.govuk_environment
  workspace               = local.workspace
}
