data "tfe_outputs" "security" {
  organization = "govuk"
  workspace    = "security-${var.govuk_environment}"
}

module "opensearch" {
  source = "../../shared-modules/opensearch-blue-green-deployment"

  opensearch_domain_name = "search-domain"

  current_live_domain = var.current_live_domain
  launch_blue_domain  = var.launch_blue_domain
  launch_green_domain = var.launch_green_domain

  blue_cluster_options  = var.blue_cluster_options
  green_cluster_options = var.green_cluster_options

  govuk_environment      = var.govuk_environment
  secrets_manager_prefix = "govuk/search-api" // pragma: allowlist secret

  read_snapshots_from_environments             = var.read_snapshots_from_environments
  account_ids_allowed_to_read_domain_snapshots = var.account_ids_allowed_to_read_domain_snapshots

  create_remote_connection_to_import_to_blue_from_green = var.create_remote_connection_to_import_to_blue_from_green
  create_remote_connection_to_import_to_green_from_blue = var.create_remote_connection_to_import_to_green_from_blue
}
