govuk_aws_state_bucket              = "govuk-terraform-steppingstone-staging"
cluster_infrastructure_state_bucket = "govuk-terraform-staging"

cluster_version               = 1.26
cluster_log_retention_in_days = 7

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

govuk_environment = "staging"

publishing_service_domain = "staging.publishing.service.gov.uk"

frontend_memcached_node_type   = "cache.t4g.medium"
shared_redis_cluster_node_type = "cache.t4g.medium"

desired_ha_replicas = 2

ckan_s3_organogram_bucket = "datagovuk-staging-ckan-organogram"
