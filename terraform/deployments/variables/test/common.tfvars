govuk_aws_state_bucket              = "govuk-terraform-steppingstone-test"
cluster_infrastructure_state_bucket = "govuk-terraform-test"

cluster_version               = 1.21
cluster_log_retention_in_days = 7
workers_default_capacity_type = "SPOT"
workers_size_desired          = 3

eks_control_plane_subnets = {
  a = { az = "eu-west-1a", cidr = "10.200.19.0/28" }
  b = { az = "eu-west-1b", cidr = "10.200.19.16/28" }
  c = { az = "eu-west-1c", cidr = "10.200.19.32/28" }
}

eks_public_subnets = {
  a = { az = "eu-west-1a", cidr = "10.200.20.0/24" }
  b = { az = "eu-west-1b", cidr = "10.200.21.0/24" }
  c = { az = "eu-west-1c", cidr = "10.200.22.0/24" }
}

eks_private_subnets = {
  a = { az = "eu-west-1a", cidr = "10.200.24.0/22" }
  b = { az = "eu-west-1b", cidr = "10.200.28.0/22" }
  c = { az = "eu-west-1c", cidr = "10.200.32.0/22" }
}

govuk_environment = "test"
force_destroy     = true

publishing_service_domain = "test.publishing.service.gov.uk"
external_dns_subdomain    = "eks"

frontend_memcached_node_type   = "cache.t4g.micro"
shared_redis_cluster_node_type = "cache.t4g.small"

# Non-production-only access is sufficient to access tools in this cluster.
dex_github_orgs_teams  = [{ name = "alphagov", teams = ["gov-uk", "gov-uk-production"] }]
github_read_write_team = "alphagov:gov-uk"

grafana_db_auto_pause   = true
rds_apply_immediately   = true
rds_skip_final_snapshot = true

secrets_recovery_window_in_days = 0
