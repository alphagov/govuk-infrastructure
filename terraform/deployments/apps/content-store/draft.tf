module "draft_container_definition" {
  source = "../../../modules/app-container-definition"
  name   = "draft-content-store"
  image  = "govuk/content-store:bill-content-schemas" # TODO use "govuk/content-store:${var.image_tag}"
  environment_variables = merge(
    local.environment_variables,
    {
      GOVUK_STATSD_PREFIX         = "govuk.app.draft-${local.app_name}.ecs"
      PLEK_SERVICE_ROUTER_API_URI = "http://draft-router-api.${local.mesh_domain}"
      MONGODB_URI                 = "mongodb://${local.mongodb_host}/draft_content_store_production"
    },
  )
  log_group             = local.log_group
  secrets_from_arns     = local.secrets_from_arns
  aws_region            = data.aws_region.current.name
  depends_on_containers = { envoy : "START" }
}

module "draft_envoy_configuration" {
  source = "../../../modules/envoy-configuration"

  mesh_name    = local.mesh_name
  service_name = "draft-content-store"
  log_group    = local.log_group
  aws_region   = data.aws_region.current.name
}

resource "aws_ecs_task_definition" "draft" {
  family                   = "draft-content-store"
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    module.draft_container_definition.value,
    module.draft_envoy_configuration.container_definition,
  ])

  network_mode       = "awsvpc"
  cpu                = 512
  memory             = 1024
  task_role_arn      = local.fargate_task_iam_role_arn
  execution_role_arn = local.fargate_execution_iam_role_arn

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"
    properties     = module.draft_envoy_configuration.proxy_properties
  }
}
