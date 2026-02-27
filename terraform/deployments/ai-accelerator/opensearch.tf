module "opensearch" {
  source = "github.com/alphagov/govuk-infrastructure/terraform/shared-modules/opensearch-blue-green-deployment?ref=136062481db579d76723705c698c087582cad157"

  opensearch_domain_name = "ai-accelerator"

  current_live_domain = var.current_live_domain
  launch_blue_domain  = var.launch_blue_domain
  launch_green_domain = var.launch_green_domain

  blue_cluster_options  = var.blue_cluster_options
  green_cluster_options = var.green_cluster_options

  govuk_environment                            = var.govuk_environment
  secrets_manager_prefix                       = "govuk/ai-accelerator" // pragma: allowlist secret
  read_snapshots_from_environments             = var.read_snapshots_from_environments
  account_ids_allowed_to_read_domain_snapshots = var.account_ids_allowed_to_read_domain_snapshots
}
