locals {
  content_store_defaults = {
    cpu    = 512  # TODO parameterize this
    memory = 1024 # TODO parameterize this

    backend_services = flatten([
      local.defaults.virtual_service_backends,
      module.signon.virtual_service_name
    ])

    environment_variables = merge(
      local.defaults.environment_variables,
      {
        GOVUK_APP_NAME                  = "content-store",
        GOVUK_CONTENT_SCHEMAS_PATH      = "/govuk-content-schemas",
        PLEK_SERVICE_PUBLISHING_API_URI = local.defaults.publishing_api_uri
        PLEK_SERVICE_SIGNON_URI         = local.defaults.signon_uri
        UNICORN_WORKER_PROCESSES        = 12,
      }
    )

    secrets_from_arns = merge(
      local.defaults.secrets_from_arns,
      {
        GDS_SSO_OAUTH_ID     = data.aws_secretsmanager_secret.content_store_oauth_id.arn,
        GDS_SSO_OAUTH_SECRET = data.aws_secretsmanager_secret.content_store_oauth_secret.arn,
        SECRET_KEY_BASE      = data.aws_secretsmanager_secret.content_store_secret_key_base.arn,
      }
    )

    mongodb_url = format(
      "mongodb://%s,%s,%s",
      data.terraform_remote_state.govuk_aws_mongo.outputs.mongo_1_service_dns_name,
      data.terraform_remote_state.govuk_aws_mongo.outputs.mongo_2_service_dns_name,
      data.terraform_remote_state.govuk_aws_mongo.outputs.mongo_3_service_dns_name,
    )
  }
}

module "content_store" {
  source = "../../modules/app"
  backend_virtual_service_names = flatten([
    local.content_store_defaults.backend_services,
    module.router_api.virtual_service_name,
  ])
  registry                         = var.registry
  image_name                       = "content-store"
  service_name                     = "content-store"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = local.vpc_id
  subnets                          = local.private_subnets
  desired_count                    = var.content_store_desired_count
  extra_security_groups = [
    local.govuk_management_access_security_group,
    aws_security_group.mesh_ecs_service.id
  ]
  environment_variables = merge(
    local.content_store_defaults.environment_variables,
    {
      GOVUK_STATSD_PREFIX         = "govuk-ecs.app.content-store"
      PLEK_SERVICE_ROUTER_API_URI = local.defaults.router_api_uri
      MONGODB_URI                 = "${local.content_store_defaults.mongodb_url}/live_content_store_production"
    },
  )
  secrets_from_arns = merge(
    local.content_store_defaults.secrets_from_arns,
    {
      # PUBLISHING_API_BEARER_TOKEN = module.content_store_to_publishing_api_bearer_token.secret_arn
      # ROUTER_API_BEARER_TOKEN     = module.content_store_to_router_api_bearer_token.secret_arn
      PUBLISHING_API_BEARER_TOKEN = data.aws_secretsmanager_secret.content_store_publishing_api_bearer_token.arn
      ROUTER_API_BEARER_TOKEN     = data.aws_secretsmanager_secret.content_store_router_api_bearer_token.arn
    }
  )
  splunk_url_secret_arn   = local.defaults.splunk_url_secret_arn
  splunk_token_secret_arn = local.defaults.splunk_token_secret_arn
  splunk_index            = local.defaults.splunk_index
  splunk_sourcetype       = local.defaults.splunk_sourcetype
  aws_region              = data.aws_region.current.name
  cpu                     = local.content_store_defaults.cpu
  memory                  = local.content_store_defaults.memory
  task_role_arn           = aws_iam_role.task.arn
  execution_role_arn      = aws_iam_role.execution.arn
  additional_tags         = local.additional_tags
  environment             = var.govuk_environment
}

module "draft_content_store" {
  source = "../../modules/app"

  service_name = "draft-content-store"
  backend_virtual_service_names = flatten([
    local.content_store_defaults.backend_services,
    module.draft_router_api.virtual_service_name,
  ])
  registry                         = var.registry
  image_name                       = "content-store"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = local.vpc_id
  subnets                          = local.private_subnets
  desired_count                    = var.draft_content_store_desired_count
  extra_security_groups = [
    local.govuk_management_access_security_group,
    aws_security_group.mesh_ecs_service.id
  ]
  environment_variables = merge(
    local.content_store_defaults.environment_variables,
    {
      GOVUK_APP_NAME              = "draft-content-store",
      GOVUK_STATSD_PREFIX         = "govuk-ecs.app.draft-content-store"
      PLEK_SERVICE_ROUTER_API_URI = local.defaults.draft_router_api_uri
      MONGODB_URI                 = "${local.content_store_defaults.mongodb_url}/draft_content_store_production"
    }
  )
  secrets_from_arns = merge(
    local.content_store_defaults.secrets_from_arns,
    {
      # PUBLISHING_API_BEARER_TOKEN = module.draft_content_store_to_publishing_api_bearer_token.secret_arn
      # ROUTER_API_BEARER_TOKEN     = module.draft_content_store_to_router_api_bearer_token.secret_arn
      PUBLISHING_API_BEARER_TOKEN = data.aws_secretsmanager_secret.content_store_publishing_api_bearer_token.arn
      ROUTER_API_BEARER_TOKEN     = data.aws_secretsmanager_secret.content_store_router_api_bearer_token.arn
    }
  )
  splunk_url_secret_arn   = local.defaults.splunk_url_secret_arn
  splunk_token_secret_arn = local.defaults.splunk_token_secret_arn
  splunk_index            = local.defaults.splunk_index
  splunk_sourcetype       = local.defaults.splunk_sourcetype
  aws_region              = data.aws_region.current.name
  cpu                     = local.content_store_defaults.cpu
  memory                  = local.content_store_defaults.memory
  task_role_arn           = aws_iam_role.task.arn
  execution_role_arn      = aws_iam_role.execution.arn
  additional_tags         = local.additional_tags
  environment             = var.govuk_environment
}
