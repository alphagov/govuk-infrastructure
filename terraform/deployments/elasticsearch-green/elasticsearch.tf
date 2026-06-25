data "tfe_outputs" "security" {
  organization = "govuk"
  workspace    = "security-${var.govuk_environment}"
}

module "opensearch" {
  source = "../../shared-modules/opensearch-blue-green-deployment"

  opensearch_domain_name = "elasticsearch6"

  current_live_domain = var.current_live_domain
  launch_blue_domain  = var.launch_blue_domain
  launch_green_domain = var.launch_green_domain

  blue_cluster_options  = var.blue_cluster_options
  green_cluster_options = var.green_cluster_options

  govuk_environment      = var.govuk_environment
  secrets_manager_prefix = "govuk/search-api" // pragma: allowlist secret

  read_snapshots_from_environments             = var.read_snapshots_from_environments
  account_ids_allowed_to_read_domain_snapshots = var.account_ids_allowed_to_read_domain_snapshots

  attach_snapshot_policy_with_role_policy_attachement = true

  s3_bucket_custom_suffix = "manual-snapshots"

  s3_bucket_additional_tags = {
    terraform_deployment = "app-elasticsearch6"
  }

  // WARNING: The following option must be removed once the existing elasticsearch 6 green cluster has been destroyed
  use_aws_elasticsearch_domain_resource_for_green_cluster    = var.use_aws_elasticsearch_domain_resource_for_green_cluster
  override_aws_elasticsearch_domain_name_for_green_cluster   = "green-elasticsearch6-domain"
  log_resource_policy_name_suffix_override_for_green_cluster = "-domain_log_write"
  override_opensearch_snapshot_policy_name                   = "govuk-${var.govuk_environment}-green-elasticsearch6-manual-snapshot-bucket-policy"
  disable_node_to_node_encryption_for_green_cluster          = true
  disable_enforced_https_for_green_cluster                   = true
  override_security_group_ids_for_green_cluster              = [data.tfe_outputs.security.nonsensitive_values.govuk_elasticsearch6_access_sg_id]
  override_custom_domain_endpoint_for_green_cluster          = "green-elasticsearch6.${var.govuk_environment}.govuk-internal.digital"
  create_additional_manual_snapshot_role_name                = "green-elasticsearch6-manual-snapshot-role"
  elasticsearch_domain_additional_tags_for_green_cluster = {
    Project       = "green"
    aws_stackname = "green"
    Name          = "green-elasticsearch6"
  }
}
