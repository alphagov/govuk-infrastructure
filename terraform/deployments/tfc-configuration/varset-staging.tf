resource "tfe_variable_set" "common_staging" {
  name        = "Staging_infrastructure"
  description = "Some description."
  global      = false
}

resource "tfe_variable" "govuk_aws_state_bucket_staging" {
  key             = "govuk_aws_state_bucket"
  value           = "govuk-terraform-steppingstone-staging"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

resource "tfe_variable" "cluster_infrastructure_state_bucket_staging" {
  key             = "cluster_infrastructure_state_bucket"
  value           = "govuk-terraform-staging"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

resource "tfe_variable" "cluster_version_staging" {
  key             = "cluster_version"
  value           = 1.24
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

resource "tfe_variable" "cluster_log_retention_in_days_staging" {
  key             = "cluster_log_retention_in_days"
  value           = 7
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

resource "tfe_variable" "eks_control_plane_subnets_staging" {
  key = "eks_control_plane_subnets"
  value = jsonencode({
    a = { az = "eu-west-1a", cidr = "10.12.19.0/28" }
    b = { az = "eu-west-1b", cidr = "10.12.19.16/28" }
    c = { az = "eu-west-1c", cidr = "10.12.19.32/28" }
  })
  category        = "terraform"
  hcl             = true
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

resource "tfe_variable" "eks_public_subnets_staging" {
  key = "eks_public_subnets"
  value = jsonencode({
    a = { az = "eu-west-1a", cidr = "10.12.20.0/24" }
    b = { az = "eu-west-1b", cidr = "10.12.21.0/24" }
    c = { az = "eu-west-1c", cidr = "10.12.22.0/24" }
  })
  category        = "terraform"
  hcl             = true
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

resource "tfe_variable" "eks_private_subnets_staging" {
  key = "eks_private_subnets"
  value = jsonencode({
    a = { az = "eu-west-1a", cidr = "10.12.24.0/22" }
    b = { az = "eu-west-1b", cidr = "10.12.28.0/22" }
    c = { az = "eu-west-1c", cidr = "10.12.32.0/22" }
  })
  category        = "terraform"
  hcl             = true
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

resource "tfe_variable" "govuk_environment_staging" {
  key             = "govuk_environment"
  value           = "staging"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

resource "tfe_variable" "publishing_service_domain_staging" {
  key             = "publishing_service_domain"
  value           = "staging.publishing.service.gov.uk"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

resource "tfe_variable" "external_dns_subdomain_staging" {
  key             = "external_dns_subdomain"
  value           = "eks"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

resource "tfe_variable" "www_dns_validation_rdata_staging" {
  key             = "www_dns_validation_rdata"
  value           = "fnvjfn8tfff6n003cf.fastly-validations.com"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

resource "tfe_variable" "frontend_memcached_node_type_staging" {
  key             = "frontend_memcached_node_type"
  value           = "cache.t4g.medium"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

resource "tfe_variable" "shared_redis_cluster_node_type_staging" {
  key             = "shared_redis_cluster_node_type"
  value           = "cache.t4g.medium"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

resource "tfe_variable" "desired_ha_replicas_staging" {
  key             = "desired_ha_replicas"
  value           = 2
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

resource "tfe_variable" "ckan_s3_organogram_bucket_staging" {
  key             = "ckan_s3_organogram_bucket"
  value           = "datagovuk-staging-ckan-organogram"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_staging.id
}

# resource "tfe_variable" "blank" {
#   key = "name"
#   value = "val"
#   category        = "terraform"
#   description     = "a useful description"
#   variable_set_id = tfe_variable_set.common_staging.id
# }
