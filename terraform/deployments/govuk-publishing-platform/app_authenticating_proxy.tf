locals {
  authenticating_proxy_defaults = {
    cpu    = 512  # TODO parameterize this
    memory = 1024 # TODO parameterize this

    backend_services = flatten([
      local.defaults.virtual_service_backends,
      module.draft_router.virtual_service_name,
      module.signon.virtual_service_name,
    ])

    environment_variables = merge(
      local.defaults.environment_variables,
      {
        GOVUK_APP_NAME          = "authenticating-proxy",
        PLEK_SERVICE_SIGNON_URI = local.defaults.signon_uri,
        GOVUK_UPSTREAM_URI      = "http://draft-router.${local.mesh_domain}",
        MONGODB_URI             = "${local.router_defaults.mongodb_url}/authenticating_proxy_production",
      }
    )

    secrets_from_arns = merge(
      local.defaults.secrets_from_arns,
      {
        GDS_SSO_OAUTH_ID     = data.aws_secretsmanager_secret.authenticating_proxy_oauth_id.arn,
        GDS_SSO_OAUTH_SECRET = data.aws_secretsmanager_secret.authenticating_proxy_oauth_secret.arn,
        JWT_AUTH_SECRET      = data.aws_secretsmanager_secret.authenticating_proxy_jwt_auth_secret.arn,
        SECRET_KEY_BASE      = data.aws_secretsmanager_secret.authenticating_proxy_secret_key_base.arn,
      }
    )
  }
}

module "authenticating_proxy" {
  registry                         = var.registry
  image_name                       = "authenticating-proxy"
  service_name                     = "authenticating-proxy"
  mesh_name                        = aws_appmesh_mesh.govuk.id
  backend_virtual_service_names    = local.authenticating_proxy_defaults.backend_services
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  vpc_id                           = local.vpc_id
  cluster_id                       = aws_ecs_cluster.cluster.id
  source                           = "../../modules/app"
  desired_count                    = var.authenticating_proxy_desired_count
  subnets                          = local.private_subnets
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  environment_variables            = local.authenticating_proxy_defaults.environment_variables
  secrets_from_arns                = local.authenticating_proxy_defaults.secrets_from_arns
  load_balancers = [{
    target_group_arn = aws_lb_target_group.authenticating_proxy.arn
    container_port   = 80
  }]
  splunk_url_secret_arn   = local.defaults.splunk_url_secret_arn
  splunk_token_secret_arn = local.defaults.splunk_token_secret_arn
  splunk_index            = local.defaults.splunk_index
  splunk_sourcetype       = local.defaults.splunk_sourcetype
  aws_region              = data.aws_region.current.name
  cpu                     = local.authenticating_proxy_defaults.cpu
  memory                  = local.authenticating_proxy_defaults.memory
  task_role_arn           = aws_iam_role.task.arn
  execution_role_arn      = aws_iam_role.execution.arn
  additional_tags         = local.additional_tags
  environment             = var.govuk_environment
  workspace               = local.workspace
}
