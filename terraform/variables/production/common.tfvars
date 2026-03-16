# Common variables for the production environment.
# Only add variables here if they are shared across multiple workspaces in the integration environment.
# Variables that are only used by a single workspace should be added to that workspace's specific tfvars file.

govuk_aws_state_bucket              = "govuk-terraform-steppingstone-production"
cluster_infrastructure_state_bucket = "govuk-terraform-production"

cluster_version               = "1.34" # Don't forget to change this in variables-test.tf too
cluster_log_retention_in_days = 731

vpc_cidr = "10.13.0.0/16"

eks_control_plane_subnets = {
  a = { az = "eu-west-1a", cidr = "10.13.19.0/28" }
  b = { az = "eu-west-1b", cidr = "10.13.19.16/28" }
  c = { az = "eu-west-1c", cidr = "10.13.19.32/28" }
}

eks_public_subnets = {
  a = { az = "eu-west-1a", cidr = "10.13.20.0/24" }
  b = { az = "eu-west-1b", cidr = "10.13.21.0/24" }
  c = { az = "eu-west-1c", cidr = "10.13.22.0/24" }
}

eks_private_subnets = {
  a = { az = "eu-west-1a", cidr = "10.13.24.0/22" }
  b = { az = "eu-west-1b", cidr = "10.13.28.0/22" }
  c = { az = "eu-west-1c", cidr = "10.13.32.0/22" }
}

legacy_private_subnets = {
  a = { az = "eu-west-1a", cidr = "10.13.4.0/24", nat = true }
  b = { az = "eu-west-1b", cidr = "10.13.5.0/24", nat = true }
  c = { az = "eu-west-1c", cidr = "10.13.6.0/24", nat = true }

  rds_a = { az = "eu-west-1a", cidr = "10.13.10.0/24", nat = false }
  rds_b = { az = "eu-west-1b", cidr = "10.13.11.0/24", nat = false }
  rds_c = { az = "eu-west-1c", cidr = "10.13.12.0/24", nat = false }

  elasticache_a = { az = "eu-west-1a", cidr = "10.13.7.0/24", nat = false }
  elasticache_b = { az = "eu-west-1b", cidr = "10.13.8.0/24", nat = false }
  elasticache_c = { az = "eu-west-1c", cidr = "10.13.9.0/24", nat = false }

  elasticsearch_a = { az = "eu-west-1a", cidr = "10.13.16.0/24", nat = false }
  elasticsearch_b = { az = "eu-west-1b", cidr = "10.13.17.0/24", nat = false }
  elasticsearch_c = { az = "eu-west-1c", cidr = "10.13.18.0/24", nat = false }
}

govuk_environment = "production"

enable_kube_state_metrics = false

enable_arm_workers_blue  = false
enable_arm_workers_green = true
enable_x86_workers       = false

publishing_service_domain = "publishing.service.gov.uk"


frontend_memcached_node_type = "cache.r6g.large"

ckan_s3_organogram_bucket = "datagovuk-production-ckan-organogram"

shared_documentdb_identifier_suffix = "-1"
