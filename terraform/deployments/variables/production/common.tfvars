govuk_aws_state_bucket              = "govuk-terraform-steppingstone-production"
cluster_infrastructure_state_bucket = "govuk-terraform-production"

cluster_version               = 1.28
cluster_log_retention_in_days = 7

eks_control_plane_subnets = {
  a = { az = "eu-west-1a", cidr = "10.13.19.0/28" }
  b = { az = "eu-west-1b", cidr = "10.13.19.16/28" }
  c = { az = "eu-west-1c", cidr = "10.13.19.32/28" }
}

eks_licensify_gateways = {
  a = { az = "eu-west-1a", cidr = "10.13.20.0/24", eip = "eipalloc-054c895a7e019c1f3" }
  b = { az = "eu-west-1b", cidr = "10.13.21.0/24", eip = "eipalloc-0d5465010fda7ba1d" }
  c = { az = "eu-west-1c", cidr = "10.13.22.0/24", eip = "eipalloc-083611260a167ea49" }
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

workers_instance_types         = ["m6i.8xlarge", "m6a.8xlarge"]
frontend_memcached_node_type   = "cache.r6g.large"
shared_redis_cluster_node_type = "cache.r6g.xlarge"

ckan_s3_organogram_bucket = "datagovuk-production-ckan-organogram"
