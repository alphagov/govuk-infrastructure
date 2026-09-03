current_live_domain = "blue"

attach_snapshot_policy_with_role_policy_attachment = true

create_remote_connection_to_import_to_blue_from_green = false

launch_blue_domain = true
blue_cluster_options = {
  engine         = "OpenSearch"
  engine_version = "3.7"

  dedicated_master = {
    instance_count = 3
    instance_type  = "c7i.xlarge.search"
  }

  instance_count = 3
  instance_type  = "r7i.xlarge.search"

  zone_awareness_enabled        = true
  multi_az_with_standby_enabled = false

  advanced_security_options = null

  endpoint_tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  ebs_options = {
    volume_size = 314
    volume_type = "gp3"
    throughput  = 350
    iops        = 3000
  }
}

launch_green_domain   = false
green_cluster_options = null

read_snapshots_from_environments = [
  "staging",
  "integration",
]

account_ids_allowed_to_read_domain_snapshots = [
  "172025368201", # Production
  "696911096973", # Staging
  "210287912431", # Integration
]

// WARNING: This _must_ be removed once the existing Search elasticsearch 6.8 green cluster has been destroyed
use_aws_elasticsearch_domain_resource_for_green_cluster = false
