# Common variables for the integration environment.
# Only add variables here if they are shared across multiple workspaces in the integration environment.
# Variables that are only used by a single workspace should be added to that workspace's specific tfvars file.

cluster_version               = "1.34"
cluster_log_retention_in_days = 731

vpc_cidr = "10.1.0.0/16"

eks_control_plane_subnets = {
  a = { az = "eu-west-1a", cidr = "10.1.19.0/28" }
  b = { az = "eu-west-1b", cidr = "10.1.19.16/28" }
  c = { az = "eu-west-1c", cidr = "10.1.19.32/28" }
}

eks_public_subnets = {
  a = { az = "eu-west-1a", cidr = "10.1.20.0/24" }
  b = { az = "eu-west-1b", cidr = "10.1.21.0/24" }
  c = { az = "eu-west-1c", cidr = "10.1.22.0/24" }
}

eks_private_subnets = {
  a = { az = "eu-west-1a", cidr = "10.1.24.0/22" }
  b = { az = "eu-west-1b", cidr = "10.1.28.0/22" }
  c = { az = "eu-west-1c", cidr = "10.1.32.0/22" }
}

legacy_private_subnets = {
  a = { az = "eu-west-1a", cidr = "10.1.4.0/24", nat = true }
  b = { az = "eu-west-1b", cidr = "10.1.5.0/24", nat = true }
  c = { az = "eu-west-1c", cidr = "10.1.6.0/24", nat = true }

  rds_a = { az = "eu-west-1a", cidr = "10.1.10.0/24", nat = false }
  rds_b = { az = "eu-west-1b", cidr = "10.1.11.0/24", nat = false }
  rds_c = { az = "eu-west-1c", cidr = "10.1.12.0/24", nat = false }

  elasticache_a = { az = "eu-west-1a", cidr = "10.1.7.0/24", nat = false }
  elasticache_b = { az = "eu-west-1b", cidr = "10.1.8.0/24", nat = false }
  elasticache_c = { az = "eu-west-1c", cidr = "10.1.9.0/24", nat = false }

  elasticsearch_a = { az = "eu-west-1a", cidr = "10.1.16.0/24", nat = false }
  elasticsearch_b = { az = "eu-west-1b", cidr = "10.1.17.0/24", nat = false }
  elasticsearch_c = { az = "eu-west-1c", cidr = "10.1.18.0/24", nat = false }

  neptune_a = { az = "eu-west-1a", cidr = "10.1.36.0/24", nat = false }
  neptune_b = { az = "eu-west-1b", cidr = "10.1.37.0/24", nat = false }
  neptune_c = { az = "eu-west-1c", cidr = "10.1.38.0/24", nat = false }
}

govuk_environment = "integration"
force_destroy     = true

enable_kube_state_metrics = true

enable_arm_workers_blue  = false
enable_arm_workers_green = true
enable_tetragon          = true
enable_x86_workers       = false

publishing_service_domain = "integration.publishing.service.gov.uk"

frontend_memcached_node_type = "cache.t4g.micro"

# Non-production-only access is sufficient to access tools in this cluster.
github_read_write_team = "alphagov:gov-uk"

grafana_db_auto_pause       = true
maintenance_window          = "Sun:04:00-Sun:06:00"
rds_apply_immediately       = true
rds_backup_retention_period = 1
rds_skip_final_snapshot     = true

secrets_recovery_window_in_days = 0

desired_ha_replicas = 1

ckan_s3_organogram_bucket = "datagovuk-integration-ckan-organogram"

licensify_documentdb_instance_count       = 1
licensify_backup_retention_period         = 1
shared_documentdb_instance_count          = 1
shared_documentdb_backup_retention_period = 1
