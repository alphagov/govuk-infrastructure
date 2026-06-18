current_live_domain = "green"

attach_snapshot_policy_with_role_policy_attachment = true

launch_blue_domain   = false
blue_cluster_options = null

launch_green_domain = true
green_cluster_otions = {
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
    volume_type = "gp3"
    throughput  = 350
    iops        = 3000
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
  log_retention_in_days            = 3
  log_group_prefix_override        = "/aws/aes/domains/"
  inline_access_policy_declaration = true
}

read_snapshots_from_environments = [
  "production",
]

account_ids_allowed_to_read_domain_snapshots = [
  "172025368201", # Production
  "696911096973", # Staging
  "210287912431", # Integration
]

// WARNING: This _must_ be removed once the existing Search elasticsearch 6.8 green cluster has been destroyed
use_aws_elasticsearch_domain_resource_for_green_cluster = true
