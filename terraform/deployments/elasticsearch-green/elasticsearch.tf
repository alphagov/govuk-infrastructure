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

  // WARNING: The following option must be removed once the existing elasticsearch 6 green cluster has been destroyed
  use_aws_elasticsearch_domain_resource_for_green_cluster  = var.use_aws_elasticsearch_domain_resource_for_green_cluster
  override_aws_elasticsearch_domain_name_for_green_cluster = "green-elasticsearch6-domain"
}
