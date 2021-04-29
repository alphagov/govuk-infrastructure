locals {
  router_defaults = {
    cpu    = 512  # TODO parameterize this
    memory = 1024 # TODO parameterize this

    backend_services = local.defaults.virtual_service_backends

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

    mongodb_url = format(
      "mongodb://%s,%s,%s",
      data.terraform_remote_state.govuk_aws_router_mongo.outputs.router_backend_1_service_dns_name,
      data.terraform_remote_state.govuk_aws_router_mongo.outputs.router_backend_2_service_dns_name,
      data.terraform_remote_state.govuk_aws_router_mongo.outputs.router_backend_3_service_dns_name,
    )
  }
}

module "router" {
  source = "../../modules/app"

  registry     = var.registry
  image_name   = "router"
  service_name = "router"
  backend_virtual_service_names = flatten([
    local.router_defaults.backend_services,
    module.static.virtual_service_name,
    module.content_store.virtual_service_name,
    module.frontend.virtual_service_name,
  ])
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = local.vpc_id
  subnets                          = local.private_subnets
  desired_count                    = var.router_desired_count
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  container_healthcheck_command    = ["/bin/sh", "-c", "exit 0"]
  environment_variables = merge(
    local.router_defaults.environment_variables,
    {
      # BACKEND_URL_calculators             = module.calculators.virtual_service_name
      # BACKEND_URL_canary-frontend         = module.canary-frontend.virtual_service_name
      # BACKEND_URL_collections             = module.collections.virtual_service_name
      # BACKEND_URL_contacts-frontend       = module.contacts-frontend.virtual_service_name
      BACKEND_URL_content-store = "http://${module.content_store.virtual_service_name}"
      # BACKEND_URL_designprinciples        = module.designprinciples.virtual_service_name
      # BACKEND_URL_email-alert-frontend    = module.email-alert-frontend.virtual_service_name
      # BACKEND_URL_email-campaign-frontend = module.email-campaign-frontend.virtual_service_name
      # BACKEND_URL_external-link-tracker   = module.external-link-tracker.virtual_service_name
      # BACKEND_URL_feedback                = module.feedback.virtual_service_name
      # BACKEND_URL_finder-frontend         = module.finder-frontend.virtual_service_name
      BACKEND_URL_frontend = "http://${module.frontend.virtual_service_name}"
      # BACKEND_URL_government-frontend     = module.government-frontend.virtual_service_name
      # BACKEND_URL_info-frontend           = module.info-frontend.virtual_service_name
      # BACKEND_URL_licencefinder           = module.licencefinder.virtual_service_name
      # BACKEND_URL_licensify               = module.licensify.virtual_service_name
      # BACKEND_URL_manuals-frontend        = module.manuals-frontend.virtual_service_name
      # BACKEND_URL_multipage-frontend      = module.multipage-frontend.virtual_service_name
      # BACKEND_URL_publicapi               = module.publicapi.virtual_service_name
      # BACKEND_URL_search-api              = module.search-api.virtual_service_name
      # BACKEND_URL_service-manual-frontend = module.service-manual-frontend.virtual_service_name
      # BACKEND_URL_smartanswers            = module.smartanswers.virtual_service_name
      # BACKEND_URL_spotlight               = module.spotlight.virtual_service_name
      BACKEND_URL_static = "http://${module.static.virtual_service_name}"
      # BACKEND_URL_tariff                  = module.tariff.virtual_service_name
      # BACKEND_URL_whitehall-frontend      = module.whitehall-frontend.virtual_service_name
      ROUTER_MONGO_DB  = "router"
      ROUTER_MONGO_URL = "${local.router_defaults.mongodb_url}/router",
    },
  )
  secrets_from_arns       = local.router_defaults.secrets_from_arns
  splunk_url_secret_arn   = local.defaults.splunk_url_secret_arn
  splunk_token_secret_arn = local.defaults.splunk_token_secret_arn
  splunk_index            = local.defaults.splunk_index
  splunk_sourcetype       = local.defaults.splunk_sourcetype
  load_balancers = [{
    target_group_arn = aws_lb_target_group.router.arn
    container_port   = 80
  }]
  aws_region         = data.aws_region.current.name
  cpu                = local.router_defaults.cpu
  memory             = local.router_defaults.memory
  task_role_arn      = aws_iam_role.task.arn
  execution_role_arn = aws_iam_role.execution.arn
  additional_tags    = local.additional_tags
  environment        = var.govuk_environment
}

module "draft_router" {
  source       = "../../modules/app"
  registry     = var.registry
  image_name   = "router"
  service_name = "draft-router"
  backend_virtual_service_names = flatten([
    local.router_defaults.backend_services,
    module.draft_static.virtual_service_name,
    module.draft_content_store.virtual_service_name,
    module.draft_frontend.virtual_service_name,
  ])
  mesh_name                        = aws_appmesh_mesh.govuk.id
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  cluster_id                       = aws_ecs_cluster.cluster.id
  vpc_id                           = local.vpc_id
  subnets                          = local.private_subnets
  desired_count                    = var.draft_router_desired_count
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  container_healthcheck_command    = ["/bin/sh", "-c", "exit 0"]
  environment_variables = merge(
    local.router_defaults.environment_variables,
    {
      # BACKEND_URL_calculators             = module.draft_calculators.virtual_service_name
      # BACKEND_URL_canary-frontend         = module.draft_canary-frontend.virtual_service_name
      # BACKEND_URL_collections             = module.draft_collections.virtual_service_name
      # BACKEND_URL_contacts-frontend       = module.draft_contacts-frontend.virtual_service_name
      BACKEND_URL_content-store = "http://${module.draft_content_store.virtual_service_name}"
      # BACKEND_URL_designprinciples        = module.draft_designprinciples.virtual_service_name
      # BACKEND_URL_email-alert-frontend    = module.draft_email-alert-frontend.virtual_service_name
      # BACKEND_URL_email-campaign-frontend = module.draft_email-campaign-frontend.virtual_service_name
      # BACKEND_URL_external-link-tracker   = module.draft_external-link-tracker.virtual_service_name
      # BACKEND_URL_feedback                = module.draft_feedback.virtual_service_name
      # BACKEND_URL_finder-frontend         = module.draft_finder-frontend.virtual_service_name
      BACKEND_URL_frontend = "http://${module.draft_frontend.virtual_service_name}"
      # BACKEND_URL_government-frontend     = module.draft_government-frontend.virtual_service_name
      # BACKEND_URL_info-frontend           = module.draft_info-frontend.virtual_service_name
      # BACKEND_URL_licencefinder           = module.draft_licencefinder.virtual_service_name
      # BACKEND_URL_licensify               = module.draft_licensify.virtual_service_name
      # BACKEND_URL_manuals-frontend        = module.draft_manuals-frontend.virtual_service_name
      # BACKEND_URL_multipage-frontend      = module.draft_multipage-frontend.virtual_service_name
      # BACKEND_URL_publicapi               = module.draft_publicapi.virtual_service_name
      # BACKEND_URL_search-api              = module.draft_search-api.virtual_service_name
      # BACKEND_URL_service-manual-frontend = module.draft_service-manual-frontend.virtual_service_name
      # BACKEND_URL_smartanswers            = module.draft_smartanswers.virtual_service_name
      # BACKEND_URL_spotlight               = module.draft_spotlight.virtual_service_name
      BACKEND_URL_static = "http://${module.draft_static.virtual_service_name}"
      # BACKEND_URL_tariff                  = module.tariff.virtual_service_name
      # BACKEND_URL_whitehall-frontend      = module.whitehall-frontend.virtual_service_name
      ROUTER_MONGO_DB  = "draft_router"
      ROUTER_MONGO_URL = "${local.router_defaults.mongodb_url}/draft_router",
    },
  )
  secrets_from_arns       = local.router_defaults.secrets_from_arns
  splunk_url_secret_arn   = local.defaults.splunk_url_secret_arn
  splunk_token_secret_arn = local.defaults.splunk_token_secret_arn
  splunk_index            = local.defaults.splunk_index
  splunk_sourcetype       = local.defaults.splunk_sourcetype
  load_balancers = [{
    target_group_arn = aws_lb_target_group.draft_router.arn
    container_port   = 80
  }]
  aws_region         = data.aws_region.current.name
  cpu                = local.router_defaults.cpu
  memory             = local.router_defaults.memory
  task_role_arn      = aws_iam_role.task.arn
  execution_role_arn = aws_iam_role.execution.arn
  additional_tags    = local.additional_tags
  environment        = var.govuk_environment
}
