resource "tfe_variable_set" "common_production" {
  name        = "Production_infrastructure"
  description = "Some description."
  global      = false
}

resource "tfe_variable" "govuk_aws_state_bucket_production" {
  key             = "govuk_aws_state_bucket"
  value           = "govuk-terraform-steppingstone-production"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

resource "tfe_variable" "cluster_infrastructure_state_bucket_production" {
  key             = "cluster_infrastructure_state_bucket"
  value           = "govuk-terraform-production"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

resource "tfe_variable" "cluster_version_production" {
  key             = "cluster_version"
  value           = 1.24
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

resource "tfe_variable" "cluster_log_retention_in_days_production" {
  key             = "cluster_log_retention_in_days"
  value           = 7
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

resource "tfe_variable" "eks_control_plane_subnets_production" {
  key = "eks_control_plane_subnets"
  value = jsonencode({
    a = { az = "eu-west-1a", cidr = "10.13.19.0/28" }
    b = { az = "eu-west-1b", cidr = "10.13.19.16/28" }
    c = { az = "eu-west-1c", cidr = "10.13.19.32/28" }
  })
  category        = "terraform"
  hcl             = true
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

resource "tfe_variable" "eks_public_subnets_production" {
  key = "eks_public_subnets"
  value = jsonencode({
    a = { az = "eu-west-1a", cidr = "10.13.20.0/24" }
    b = { az = "eu-west-1b", cidr = "10.13.21.0/24" }
    c = { az = "eu-west-1c", cidr = "10.13.22.0/24" }
  })
  category        = "terraform"
  hcl             = true
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

resource "tfe_variable" "eks_private_subnets_production" {
  key = "eks_private_subnets"
  value = jsonencode({
    a = { az = "eu-west-1a", cidr = "10.13.24.0/22" }
    b = { az = "eu-west-1b", cidr = "10.13.28.0/22" }
    c = { az = "eu-west-1c", cidr = "10.13.32.0/22" }
  })
  category        = "terraform"
  hcl             = true
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

resource "tfe_variable" "govuk_environment_production" {
  key             = "govuk_environment"
  value           = "production"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

resource "tfe_variable" "publishing_service_domain_production" {
  key             = "publishing_service_domain"
  value           = "publishing.service.gov.uk"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

resource "tfe_variable" "external_dns_subdomain_production" {
  key             = "external_dns_subdomain"
  value           = "eks"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

resource "tfe_variable" "www_dns_validation_rdata_production" {
  key             = "www_dns_validation_rdata"
  value           = "sb6euj4c7g7s54y1pi.fastly-validations.com"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

resource "tfe_variable" "workers_instance_types_production" {
  key             = "workers_instance_types"
  value           = jsonencode(["m6i.8xlarge", "m6a.8xlarge"])
  category        = "terraform"
  hcl             = true
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

resource "tfe_variable" "frontend_memcached_node_type_production" {
  key             = "frontend_memcached_node_type"
  value           = "cache.r6g.large"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

resource "tfe_variable" "shared_redis_cluster_node_type_production" {
  key             = "shared_redis_cluster_node_type"
  value           = "cache.r6g.large"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

resource "tfe_variable" "ckan_s3_organogram_bucket_production" {
  key             = "ckan_s3_organogram_bucket"
  value           = "datagovuk-production-ckan-organogram"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_production.id
}

# resource "tfe_variable" "blank" {
#   key = "name"
#   value = "val"
#   category        = "terraform"
#   description     = "a useful description"
#   variable_set_id = tfe_variable_set.common_production.id
# }
