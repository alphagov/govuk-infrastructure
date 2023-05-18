resource "tfe_variable_set" "common_integration" {
  name        = "Integration_infrastructure"
  description = "Some description."
  global      = false
}

resource "tfe_variable" "govuk_aws_state_bucket_integration" {
  key             = "govuk_aws_state_bucket"
  value           = "govuk-terraform-steppingstone-integration"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "cluster_infrastructure_state_bucket_integration" {
  key             = "cluster_infrastructure_state_bucket"
  value           = "govuk-terraform-integration"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "cluster_version_integration" {
  key             = "cluster_version"
  value           = 1.24
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "cluster_log_retention_in_days_integration" {
  key             = "cluster_log_retention_in_days"
  value           = 7
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "eks_control_plane_subnets_integration" {
  key = "eks_control_plane_subnets"
  value = jsonencode({
    a = { az = "eu-west-1a", cidr = "10.1.19.0/28" }
    b = { az = "eu-west-1b", cidr = "10.1.19.16/28" }
    c = { az = "eu-west-1c", cidr = "10.1.19.32/28" }
  })
  category        = "terraform"
  hcl             = true
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "eks_public_subnets_integration" {
  key = "eks_public_subnets"
  value = jsonencode({
    a = { az = "eu-west-1a", cidr = "10.1.20.0/24" }
    b = { az = "eu-west-1b", cidr = "10.1.21.0/24" }
    c = { az = "eu-west-1c", cidr = "10.1.22.0/24" }
  })
  category        = "terraform"
  hcl             = true
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "eks_private_subnets_integration" {
  key = "eks_private_subnets"
  value = jsonencode({
    a = { az = "eu-west-1a", cidr = "10.1.24.0/22" }
    b = { az = "eu-west-1b", cidr = "10.1.28.0/22" }
    c = { az = "eu-west-1c", cidr = "10.1.32.0/22" }
  })
  category        = "terraform"
  hcl             = true
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "govuk_environment_integration" {
  key             = "govuk_environment"
  value           = "integration"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "force_destroy_integration" {
  key             = "force_destroy"
  value           = "true"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "publishing_service_domain_integration" {
  key             = "publishing_service_domain"
  value           = "integration.publishing.service.gov.uk"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "external_dns_subdomain_integration" {
  key             = "external_dns_subdomain"
  value           = "eks"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "www_dns_validation_rdata_integration" {
  key             = "www_dns_validation_rdata"
  value           = "8xpwlbcbmg9qjx9d2v.fastly-validations.com"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "frontend_memcached_node_type_integration" {
  key             = "frontend_memcached_node_type"
  value           = "cache.t4g.micro"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "shared_redis_cluster_node_type_integration" {
  key             = "shared_redis_cluster_node_type"
  value           = "cache.t4g.small"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "github_read_write_team_integration" {
  key             = "github_read_write_team"
  value           = "alphagov:gov-uk"
  category        = "terraform"
  description     = "Non-production-only access is sufficient to access tools in this cluster."
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "grafana_db_auto_pause_integration" {
  key             = "grafana_db_auto_pause"
  value           = true
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "rds_apply_immediately_integration" {
  key             = "rds_apply_immediately"
  value           = true
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "rds_skip_final_snapshot_integration" {
  key             = "rds_skip_final_snapshot"
  value           = true
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "secrets_recovery_window_in_days_integration" {
  key             = "secrets_recovery_window_in_days"
  value           = 0
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "argo_redis_ha_integration" {
  key             = "argo_redis_ha"
  value           = false
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "desired_ha_replicas_integration" {
  key             = "desired_ha_replicas"
  value           = 1
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

resource "tfe_variable" "ckan_s3_organogram_bucket_integration" {
  key             = "ckan_s3_organogram_bucket"
  value           = "datagovuk-integration-ckan-organogram"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.common_integration.id
}

# resource "tfe_variable" "blank" {
#   key = "name"
#   value = "val"
#   category        = "terraform"
#   description     = "a useful description"
#   variable_set_id = tfe_variable_set.common_integration.id
# }
