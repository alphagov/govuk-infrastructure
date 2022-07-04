govuk_aws_state_bucket              = "govuk-terraform-steppingstone-production"
cluster_infrastructure_state_bucket = "govuk-terraform-production"

cluster_version               = 1.21
cluster_log_retention_in_days = 7

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

govuk_environment = "production"

publishing_service_domain = "publishing.service.gov.uk"
external_dns_subdomain    = "eks"

www_dns_validation_rdata = "sb6euj4c7g7s54y1pi.fastly-validations.com"

frontend_memcached_node_type   = "cache.t4g.medium"
shared_redis_cluster_node_type = "cache.t4g.medium"
