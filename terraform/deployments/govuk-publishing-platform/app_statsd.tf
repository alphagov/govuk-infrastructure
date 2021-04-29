# TODO: Add Concourse deployment for statsd if/when necessary
locals {
  statsd_defaults = {
    cpu                   = 1024 # TODO parameterize this
    memory                = 2048 # TODO parameterize this
    environment_variables = local.defaults.environment_variables
    secrets_from_arns     = local.defaults.secrets_from_arns
  }
}

module "statsd" {
  aws_region                       = data.aws_region.current.name
  backend_virtual_service_names    = [] # TODO: Add EC2 Graphite?
  cluster_id                       = aws_ecs_cluster.cluster.id
  cpu                              = local.statsd_defaults.cpu
  desired_count                    = var.statsd_desired_count
  environment_variables            = local.statsd_defaults.environment_variables
  execution_role_arn               = aws_iam_role.execution.arn
  extra_security_groups            = [local.govuk_management_access_security_group, aws_security_group.mesh_ecs_service.id]
  image_name                       = "statsd"
  image_tag                        = "test-0.1.3" # TODO: https://trello.com/c/nju3j7Ph/38-modify-statsd-so-that-we-can-run-it-in-ecs
  memory                           = local.statsd_defaults.memory
  mesh_name                        = aws_appmesh_mesh.govuk.id
  registry                         = var.registry
  secrets_from_arns                = local.statsd_defaults.secrets_from_arns
  service_discovery_namespace_id   = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  service_discovery_namespace_name = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  service_name                     = "statsd"
  source                           = "../../modules/app"
  subnets                          = local.private_subnets
  task_role_arn                    = aws_iam_role.task.arn
  vpc_id                           = local.vpc_id
  splunk_url_secret_arn            = local.defaults.splunk_url_secret_arn
  splunk_token_secret_arn          = local.defaults.splunk_token_secret_arn
  splunk_index                     = local.defaults.splunk_index
  splunk_sourcetype                = local.defaults.splunk_sourcetype
  additional_tags                  = local.additional_tags
  environment                      = var.govuk_environment
}
