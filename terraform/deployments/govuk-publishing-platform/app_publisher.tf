locals {
  publisher_app_name = "publisher"

  publisher_defaults = {
    cpu    = 512  # TODO parameterize this
    memory = 1024 # TODO parameterize this

    backend_services = flatten([
      local.defaults.virtual_service_backends,
      module.signon.virtual_service_names,
      module.publishing_api_web.virtual_service_names,
    ])

    environment_variables = merge(
      local.defaults.environment_variables,
      {
        ASSET_HOST                       = local.defaults.asset_host
        BASIC_AUTH_USERNAME              = "gds"
        EMAIL_GROUP_BUSINESS             = "test-address@digital.cabinet-office.gov.uk"
        EMAIL_GROUP_CITIZEN              = "test-address@digital.cabinet-office.gov.uk"
        EMAIL_GROUP_DEV                  = "test-address@digital.cabinet-office.gov.uk"
        EMAIL_GROUP_FORCE_PUBLISH_ALERTS = "test-address@digital.cabinet-office.gov.uk"
        FACT_CHECK_SUBJECT_PREFIX        = "dev"
        FACT_CHECK_USERNAME              = "govuk-fact-check-test@digital.cabinet-office.gov.uk"
        GOVUK_APP_DOMAIN_EXTERNAL        = var.external_app_domain
        GOVUK_APP_NAME                   = local.publisher_app_name
        GOVUK_APP_ROOT                   = "/app"
        # TODO: how does GOVUK_ASSET_ROOT relate to ASSET_HOST? Is one a function of the other? Are they both really in use? Is GOVUK_ASSET_ROOT always just "https://${ASSET_HOST}"?
        GOVUK_ASSET_ROOT                = local.defaults.asset_root_url
        GOVUK_STATSD_PREFIX             = "govuk-ecs.app.${local.publisher_app_name}"
        PLEK_SERVICE_CONTENT_STORE_URI  = local.defaults.content_store_uri
        PLEK_SERVICE_PUBLISHING_API_URI = local.defaults.publishing_api_uri
        PLEK_SERVICE_SIGNON_URI         = local.defaults.signon_uri
        PLEK_SERVICE_STATIC_URI         = local.defaults.static_uri
        # TODO: remove PLEK_SERVICE_DRAFT_ORIGIN_URI once we have the draft origin properly set up with multiple frontends
        PLEK_SERVICE_DRAFT_ORIGIN_URI = local.defaults.draft_origin_uri
        # TODO: temporary hack
        RAILS_SERVE_STATIC_FILES = "true"
        # TODO: we shouldn't be specifying both REDIS_{HOST,PORT} *and* REDIS_URL.
        REDIS_HOST   = var.redis_host
        REDIS_PORT   = tostring(var.redis_port)
        REDIS_URL    = local.defaults.redis_url
        WEBSITE_ROOT = local.defaults.website_root
      }
    )

    secrets_from_arns = merge(
      local.defaults.secrets_from_arns,
      {
        ASSET_MANAGER_BEARER_TOKEN    = data.aws_secretsmanager_secret.publisher_asset_manager_bearer_token.arn,
        FACT_CHECK_PASSWORD           = data.aws_secretsmanager_secret.publisher_fact_check_password.arn,
        FACT_CHECK_REPLY_TO_ADDRESS   = data.aws_secretsmanager_secret.publisher_fact_check_reply_to_address.arn,
        FACT_CHECK_REPLY_TO_ID        = data.aws_secretsmanager_secret.publisher_fact_check_reply_to_id.arn,
        GOVUK_NOTIFY_API_KEY          = data.aws_secretsmanager_secret.publisher_govuk_notify_api_key.arn,
        GOVUK_NOTIFY_TEMPLATE_ID      = data.aws_secretsmanager_secret.publisher_govuk_notify_template_id.arn,
        JWT_AUTH_SECRET               = data.aws_secretsmanager_secret.publisher_jwt_auth_secret.arn,
        LINK_CHECKER_API_BEARER_TOKEN = data.aws_secretsmanager_secret.publisher_link_checker_api_bearer_token.arn,
        LINK_CHECKER_API_SECRET_TOKEN = data.aws_secretsmanager_secret.publisher_link_checker_api_secret_token.arn,
        # TODO: Only the password should be a secret in the MONGODB_URI.
        MONGODB_URI                 = data.aws_secretsmanager_secret.publisher_mongodb_uri.arn,
        GDS_SSO_OAUTH_ID            = data.aws_secretsmanager_secret.publisher_oauth_id.arn,
        GDS_SSO_OAUTH_SECRET        = data.aws_secretsmanager_secret.publisher_oauth_secret.arn,
        PUBLISHING_API_BEARER_TOKEN = data.aws_secretsmanager_secret.publisher_publishing_api_bearer_token.arn,
        SECRET_KEY_BASE             = data.aws_secretsmanager_secret.publisher_secret_key_base.arn,
      }
    )
  }
}

module "publisher_web" {
  image_name                       = "publisher"
  service_name                     = "publisher-web"
  backend_virtual_service_names    = local.publishing_api_defaults.backend_services
  cluster_id                       = aws_ecs_cluster.cluster.id
  mesh_name                        = aws_appmesh_mesh.govuk.id
  subnets                          = local.private_subnets
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  source                           = "../../modules/app"
  vpc_id                           = local.vpc_id
  desired_count                    = var.publisher_desired_count
  extra_security_groups = [
    local.govuk_management_access_security_group,
    aws_security_group.mesh_ecs_service.id
  ]
  load_balancers = [{
    target_group_arn = module.publisher_public_alb.target_group_arn
    container_port   = 80
  }]
  command               = ["foreman", "run", "web"]
  environment_variables = local.publisher_defaults.environment_variables
  secrets_from_arns     = local.publisher_defaults.secrets_from_arns
  log_group             = local.log_group
  aws_region            = data.aws_region.current.name
  cpu                   = local.publisher_defaults.cpu
  memory                = local.publisher_defaults.memory
  task_role_arn         = aws_iam_role.task.arn
  execution_role_arn    = aws_iam_role.execution.arn
}

#
# Internet-facing load balancer
#

module "publisher_public_alb" {
  source = "../../modules/public-load-balancer"

  app_name                  = local.publisher_app_name
  vpc_id                    = local.vpc_id
  dns_a_record_name         = "publisher"
  public_subnets            = local.public_subnets
  external_app_domain       = var.external_app_domain
  publishing_service_domain = var.publishing_service_domain
  workspace_suffix          = "${terraform.workspace == "default" ? "govuk" : "${terraform.workspace}"}"
  service_security_group_id = module.publisher_web.security_group_id
  external_cidrs_list       = var.office_cidrs_list
}

#
# Sidekiq Worker Service
#
module "publisher_worker" {
  image_name                    = "publisher"
  service_name                  = "publisher-worker"
  backend_virtual_service_names = local.publishing_api_defaults.backend_services
  command                       = ["foreman", "run", "worker"]
  cluster_id                    = aws_ecs_cluster.cluster.id
  extra_security_groups = [
    module.publisher_web.security_group_id,
    local.govuk_management_access_security_group,
    aws_security_group.mesh_ecs_service.id
  ]
  environment_variables            = local.publisher_defaults.environment_variables
  mesh_name                        = aws_appmesh_mesh.govuk.id
  subnets                          = local.private_subnets
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  source                           = "../../modules/app"
  secrets_from_arns                = local.publisher_defaults.secrets_from_arns
  log_group                        = local.log_group
  aws_region                       = data.aws_region.current.name
  cpu                              = local.publisher_defaults.cpu
  memory                           = local.publisher_defaults.memory
  task_role_arn                    = aws_iam_role.task.arn
  execution_role_arn               = aws_iam_role.execution.arn
  vpc_id                           = local.vpc_id
}
