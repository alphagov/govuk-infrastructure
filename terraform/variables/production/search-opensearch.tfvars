current_live_domain = "green"

launch_blue_domain   = false
blue_cluster_options = null

launch_green_domain = true
green_cluster_options = {
  engine         = "OpenSearch"
  engine_version = "3.7"

  dedicated_master = {
    instance_count = 3
    instance_type  = "c7g.xlarge.search"
  }

  instance_count = 3
  instance_type  = "r7g.4xlarge.search"

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

read_snapshots_from_environments = [
  "production",
]

account_ids_allowed_to_read_domain_snapshots = [
  "172025368201", # Production
  "696911096973", # Staging
  "210287912431", # Integration
]
