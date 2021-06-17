locals {
  publishing_api_defaults = {
    cpu    = 512  # TODO parameterize this
    memory = 1024 # TODO parameterize this

    backend_services = flatten([
      local.defaults.virtual_service_backends,
      module.signon.virtual_service_name,
      module.content_store.virtual_service_name,
      module.draft_content_store.virtual_service_name,
    ])

    environment_variables = merge(
      local.defaults.environment_variables,
      {
        # TODO: factor our hardcoded stuff
        CONTENT_API_PROTOTYPE    = "yes"
        CONTENT_STORE            = local.defaults.content_store_uri
        DRAFT_CONTENT_STORE      = local.defaults.draft_content_store_uri
        EVENT_LOG_AWS_ACCESS_ID  = "AKIAJE6VSW25CYBUMQJA" # pragma: allowlist secret
        EVENT_LOG_AWS_BUCKETNAME = "govuk-publishing-api-event-log-test"
        EVENT_LOG_AWS_USERNAME   = "govuk-publishing-api-event-log_user"
        GOVUK_APP_NAME           = "publishing-api"
        # TODO: Remove once content-schemas issue is fixed
        GOVUK_CONTENT_SCHEMAS_PATH           = "/govuk-content-schemas"
        GOVUK_STATSD_PREFIX                  = "govuk-ecs.app.publishing-api"
        PLEK_SERVICE_CONTENT_STORE_URI       = local.defaults.content_store_uri
        PLEK_SERVICE_DRAFT_CONTENT_STORE_URI = local.defaults.draft_content_store_uri
        PLEK_SERVICE_SIGNON_URI              = local.defaults.signon_uri
        RABBITMQ_HOSTS                       = local.defaults.rabbitmq_hosts
        RABBITMQ_USER                        = "publishing_api"
        RABBITMQ_VHOST                       = "/"
        REDIS_URL                            = module.shared_redis_cluster.uri
        UNICORN_WORKER_PROCESSES             = "8"
      }
    )

    secrets_from_arns = merge(
      local.defaults.secrets_from_arns,
      {
        CONTENT_STORE_BEARER_TOKEN       = module.signon_bearer_tokens.pub_api_to_cs.secret_arn_value
        DATABASE_URL                     = data.aws_secretsmanager_secret.publishing_api_database_url.arn
        DRAFT_CONTENT_STORE_BEARER_TOKEN = module.signon_bearer_tokens.pub_api_to_dcs.secret_arn_value
        EVENT_LOG_AWS_SECRET_KEY         = data.aws_secretsmanager_secret.publishing_api_event_log_aws_secret_key.arn
        GDS_SSO_OAUTH_ID                 = module.oauth_applications["publishing_api"].id_arn
        GDS_SSO_OAUTH_SECRET             = module.oauth_applications["publishing_api"].secret_arn
        RABBITMQ_PASSWORD                = data.aws_secretsmanager_secret.publishing_api_rabbitmq_password.arn
        ROUTER_API_BEARER_TOKEN          = module.signon_bearer_tokens.pub_api_to_router_api.secret_arn_value
        SECRET_KEY_BASE                  = aws_secretsmanager_secret.secret_key_base["publishing_api"].arn
      }
    )
  }
}

module "publishing_api_web" {
  registry                         = var.registry
  image_name                       = "publishing-api"
  service_name                     = "publishing-api-web"
  backend_virtual_service_names    = local.publishing_api_defaults.backend_services
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/app"
  desired_count                    = var.publishing_api_desired_count
  extra_security_groups            = [aws_security_group.mesh_ecs_service.id]
  subnets                          = local.private_subnets
  environment_variables            = local.publishing_api_defaults.environment_variables
  secrets_from_arns                = local.publishing_api_defaults.secrets_from_arns
  splunk_url_secret_arn            = local.defaults.splunk_url_secret_arn
  splunk_token_secret_arn          = local.defaults.splunk_token_secret_arn
  splunk_index                     = local.defaults.splunk_index
  splunk_sourcetype                = local.defaults.splunk_sourcetype
  aws_region                       = data.aws_region.current.name
  cpu                              = local.publishing_api_defaults.cpu
  memory                           = local.publishing_api_defaults.memory
  task_role_arn                    = aws_iam_role.task.arn
  execution_role_arn               = aws_iam_role.execution.arn
  additional_tags                  = local.additional_tags
  environment                      = var.govuk_environment
  workspace                        = local.workspace
  command                          = ["foreman", "run", "web"]
}

module "publishing_api_worker" {
  registry                         = var.registry
  image_name                       = "publishing-api"
  service_name                     = "publishing-api-worker"
  backend_virtual_service_names    = local.publishing_api_defaults.backend_services
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/app"
  desired_count                    = var.publishing_api_worker_desired_count
  extra_security_groups            = [module.publishing_api_web.security_group_id, aws_security_group.mesh_ecs_service.id]
  container_healthcheck_command    = ["/bin/sh", "-c", "exit 0"]
  subnets                          = local.private_subnets
  environment_variables            = local.publishing_api_defaults.environment_variables
  secrets_from_arns                = local.publishing_api_defaults.secrets_from_arns
  splunk_url_secret_arn            = local.defaults.splunk_url_secret_arn
  splunk_token_secret_arn          = local.defaults.splunk_token_secret_arn
  splunk_index                     = local.defaults.splunk_index
  splunk_sourcetype                = local.defaults.splunk_sourcetype
  aws_region                       = data.aws_region.current.name
  cpu                              = local.publishing_api_defaults.cpu
  memory                           = local.publishing_api_defaults.memory
  task_role_arn                    = aws_iam_role.task.arn
  execution_role_arn               = aws_iam_role.execution.arn
  additional_tags                  = local.additional_tags
  environment                      = var.govuk_environment
  workspace                        = local.workspace
  command                          = ["foreman", "run", "worker"]
}
