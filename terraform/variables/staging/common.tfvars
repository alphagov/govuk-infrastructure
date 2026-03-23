# Common variables for the staging environment.
# Only add variables here if they are shared across multiple workspaces in the staging environment.
# Variables that are only used by a single workspace should be added to that workspace's specific tfvars file.

cluster_version               = "1.34"
cluster_log_retention_in_days = 731

vpc_cidr = "10.12.0.0/16"

eks_control_plane_subnets = {
  a = { az = "eu-west-1a", cidr = "10.12.19.0/28" }
  b = { az = "eu-west-1b", cidr = "10.12.19.16/28" }
  c = { az = "eu-west-1c", cidr = "10.12.19.32/28" }
}

eks_public_subnets = {
  a = { az = "eu-west-1a", cidr = "10.12.20.0/24" }
  b = { az = "eu-west-1b", cidr = "10.12.21.0/24" }
  c = { az = "eu-west-1c", cidr = "10.12.22.0/24" }
}

eks_private_subnets = {
  a = { az = "eu-west-1a", cidr = "10.12.24.0/22" }
  b = { az = "eu-west-1b", cidr = "10.12.28.0/22" }
  c = { az = "eu-west-1c", cidr = "10.12.32.0/22" }
}

legacy_private_subnets = {
  a = { az = "eu-west-1a", cidr = "10.12.4.0/24", nat = true }
  b = { az = "eu-west-1b", cidr = "10.12.5.0/24", nat = true }
  c = { az = "eu-west-1c", cidr = "10.12.6.0/24", nat = true }

  rds_a = { az = "eu-west-1a", cidr = "10.12.10.0/24", nat = false }
  rds_b = { az = "eu-west-1b", cidr = "10.12.11.0/24", nat = false }
  rds_c = { az = "eu-west-1c", cidr = "10.12.12.0/24", nat = false }

  elasticache_a = { az = "eu-west-1a", cidr = "10.12.7.0/24", nat = false }
  elasticache_b = { az = "eu-west-1b", cidr = "10.12.8.0/24", nat = false }
  elasticache_c = { az = "eu-west-1c", cidr = "10.12.9.0/24", nat = false }

  elasticsearch_a = { az = "eu-west-1a", cidr = "10.12.16.0/24", nat = false }
  elasticsearch_b = { az = "eu-west-1b", cidr = "10.12.17.0/24", nat = false }
  elasticsearch_c = { az = "eu-west-1c", cidr = "10.12.18.0/24", nat = false }
}

govuk_environment = "staging"

publishing_service_domain = "staging.publishing.service.gov.uk"
