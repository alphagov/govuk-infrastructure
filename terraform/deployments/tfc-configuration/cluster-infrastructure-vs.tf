resource "tfe_variable_set" "cluster_infrastructure_integration" {
  name        = "cluster-infrastructure-integration"
  description = "Variables for cluster Infrastructure"
  global      = false
}
resource "tfe_variable" "govuk_aws_state_bucket_integration" {
  key             = "govuk_aws_state_bucket"
  value           = "govuk-terraform-steppingstone-integration"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.cluster_infrastructure_integration.id
}
resource "tfe_variable" "cluster_version_integration" {
  key             = "cluster_version"
  value           = 1.27
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.cluster_infrastructure_integration.id
}
resource "tfe_variable" "cluster_log_retention_in_days_integration" {
  key             = "cluster_log_retention_in_days"
  value           = 7
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.cluster_infrastructure_integration.id
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
  variable_set_id = tfe_variable_set.cluster_infrastructure_integration.id
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
  variable_set_id = tfe_variable_set.cluster_infrastructure_integration.id
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
  variable_set_id = tfe_variable_set.cluster_infrastructure_integration.id
}
resource "tfe_variable" "force_destroy_integration" {
  key             = "force_destroy"
  value           = "true"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.cluster_infrastructure_integration.id
}
resource "tfe_variable" "publishing_service_domain_integration" {
  key             = "publishing_service_domain"
  value           = "integration.publishing.service.gov.uk"
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.cluster_infrastructure_integration.id
}
resource "tfe_variable" "grafana_db_auto_pause_integration" {
  key             = "grafana_db_auto_pause"
  value           = true
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.cluster_infrastructure_integration.id
}

resource "tfe_variable" "rds_apply_immediately_integration" {
  key             = "rds_apply_immediately"
  value           = true
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.cluster_infrastructure_integration.id
}
resource "tfe_variable" "rds_backup_retention_period_integration" {
  key             = "rds_backup_retention_period"
  value           = 1
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.cluster_infrastructure_integration.id
}

resource "tfe_variable" "rds_skip_final_snapshot_integration" {
  key             = "rds_skip_final_snapshot"
  value           = true
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.cluster_infrastructure_integration.id
}

resource "tfe_variable" "secrets_recovery_window_in_days_integration" {
  key             = "secrets_recovery_window_in_days"
  value           = 0
  category        = "terraform"
  description     = "a useful description"
  variable_set_id = tfe_variable_set.cluster_infrastructure_integration.id
}
