data "aws_caller_identity" "current" {}

module "opensearch" {
  source = "../../shared-modules/opensearch-blue-green-deployment"

  opensearch_domain_name = "elasticsearch-domain"

  current_live_domain = "green"
  launch_blue_domain  = false
  launch_green_domain = true

  blue_cluster_options = null
  green_cluster_options = {
    engine         = "Elasticsearch"
    engine_version = "6.8"
    dedicated_master = {
      instance_count = 3
      instance_type  = "c7i.xlarge.elasticsearch"
    }

    instance_type  = "r7i.4xlarge.elasticsearch"
    instance_count = 3

    zone_awareness_enabled = true

    advanced_security_options = null

    endpoint_tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
    ebs_options = {
      volume_size = 314
      volume_type = "gp3" # FIXME
      throughput  = 250
    }

    // WARNING: All the following options are purely to allow importing the existing ES6 cluster,
    //          when creating the next blue deployment remove these options and use the defaults
    prefix_colour_instead_of_suffix = true
    disable_audit_logs              = true
    log_group_name_overrides = {
      error_logs       = "es6-application-logs"
      index_slow_logs  = "es6-index-logs"
      search_slow_logs = "es6-search-logs"
    }
    cloudwatch_log_retention_in_days = 3
  }

  govuk_environment      = var.govuk_environment
  secrets_manager_prefix = "govuk/ai-accelerator" // pragma: allowlist secret
  read_snapshots_from_environments = concat(
    [data.aws_caller_identity.current.account_id],
    var.other_account_ids_to_read_snapshots_from,
  )
  account_ids_allowed_to_read_domain_snapshots = var.account_ids_allowed_to_read_domain_snapshots

  attach_snapshot_policy_with_role_policy_attachement = true
}
