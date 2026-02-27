locals {
  security_group_ids = [aws_security_group.opensearch.id]
  subnet_ids = sort([
    for name, subnet_id in data.tfe_outputs.vpc.nonsensitive_values.private_subnet_ids
    : subnet_id if startswith(name, "elasticsearch_")
  ])
}

module "blue_domain" {
  count = var.launch_blue_domain ? 1 : 0

  source = "./opensearch-domain"

  opensearch_domain_name        = "${var.opensearch_domain_name}-blue"
  engine                        = var.blue_cluster_options.engine
  engine_version                = var.blue_cluster_options.engine_version
  instance_count                = var.blue_cluster_options.instance_count
  instance_type                 = var.blue_cluster_options.instance_type
  zone_awareness_enabled        = var.blue_cluster_options.zone_awareness_enabled
  multi_az_with_standby_enabled = !startswith(var.blue_cluster_options.instance_type, "t")
  dedicated_master              = var.blue_cluster_options.dedicated_master
  endpoint_tls_security_policy  = var.blue_cluster_options.endpoint_tls_security_policy
  ebs_options                   = var.blue_cluster_options.ebs_options

  advanced_security_options = {
    anonymous_auth_enabled         = var.blue_cluster_options.advanced_security_options.anonymous_auth_enabled
    internal_user_database_enabled = var.blue_cluster_options.advanced_security_options.internal_user_database_enabled
    master_user_options = {
      master_user_name     = local.master_user
      master_user_password = random_password.password.result
    }
  }

  govuk_environment  = var.govuk_environment
  security_group_ids = local.security_group_ids
  subnet_ids         = local.subnet_ids
  custom_endpoint    = local.service_record_name
}

module "green_domain" {
  count = var.launch_green_domain ? 1 : 0

  source = "./opensearch-domain"

  opensearch_domain_name        = "${var.opensearch_domain_name}-green"
  engine                        = var.green_cluster_options.engine
  engine_version                = var.green_cluster_options.engine_version
  instance_count                = var.green_cluster_options.instance_count
  instance_type                 = var.green_cluster_options.instance_type
  zone_awareness_enabled        = var.green_cluster_options.zone_awareness_enabled
  multi_az_with_standby_enabled = !startswith(var.green_cluster_options.instance_type, "t")
  dedicated_master              = var.green_cluster_options.dedicated_master
  endpoint_tls_security_policy  = var.green_cluster_options.endpoint_tls_security_policy
  ebs_options                   = var.green_cluster_options.ebs_options

  advanced_security_options = {
    anonymous_auth_enabled         = var.green_cluster_options.advanced_security_options.anonymous_auth_enabled
    internal_user_database_enabled = var.green_cluster_options.advanced_security_options.internal_user_database_enabled
    master_user_options = {
      master_user_name     = local.master_user
      master_user_password = random_password.password.result
    }
  }

  govuk_environment  = var.govuk_environment
  security_group_ids = local.security_group_ids
  subnet_ids         = local.subnet_ids
  custom_endpoint    = local.service_record_name
}
