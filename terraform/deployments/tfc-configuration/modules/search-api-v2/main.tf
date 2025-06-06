locals {
  display_name = title(var.name)
}

data "tfe_oauth_client" "github" {
  organization     = var.tfc_organization_name
  service_provider = "github"
}

resource "tfe_workspace" "environment_workspace" {
  name        = "search-api-v2-${var.name}"
  project_id  = var.tfc_project.id
  description = "Provisions search-api-v2 Discovery Engine resources for the ${local.display_name} environment"
  tag_names   = ["govuk", "search-api-v2", "search-api-v2-environment", var.name]

  source_name = "search-v2-infrastructure meta module"
  source_url  = "https://github.com/alphagov/search-v2-infrastructure/tree/main/terraform/meta"

  working_directory = "terraform/deployments/search-api-v2"
  terraform_version = "~> 1.12.0"

  # Don't auto-apply in production (to allow catching issues in lower environments)
  auto_apply = var.name != "production"

  file_triggers_enabled = true
  trigger_patterns = [
    "/terraform/deployments/search-api-v2/**/*.tf",
    "/terraform/deployments/search-api-v2/**/files/**/*",
  ]

  vcs_repo {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = var.vcs_repo_branch
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }
}

resource "tfe_workspace_settings" "environment_workspace_settings" {
  workspace_id = tfe_workspace.environment_workspace.id

  execution_mode = "remote"
}

data "tfe_variable_set" "aws_credentials" {
  name = "aws-credentials-${var.name}"
}

resource "tfe_workspace_variable_set" "aws_workspace_credentials" {
  variable_set_id = data.tfe_variable_set.aws_credentials.id
  workspace_id    = tfe_workspace.environment_workspace.id
}

resource "tfe_variable" "gcp_project_id" {
  workspace_id = tfe_workspace.environment_workspace.id
  category     = "terraform"
  description  = "The GCP project ID for the ${local.display_name} environment"

  key       = "gcp_project_id"
  value     = var.google_project_id
  sensitive = false
}

resource "tfe_variable" "gcp_env" {

  workspace_id = tfe_workspace.environment_workspace.id
  category     = "terraform"
  description  = "The GCP environment"

  key       = "gcp_env"
  value     = var.name
  sensitive = false
}

resource "tfe_variable" "gcp_project_number" {
  workspace_id = tfe_workspace.environment_workspace.id
  category     = "terraform"
  description  = "The GCP project number for the ${local.display_name} environment"

  key       = "gcp_project_number"
  value     = var.google_project_number
  sensitive = false
}

resource "tfe_variable" "enable_gcp_provider_auth" {
  workspace_id = tfe_workspace.environment_workspace.id

  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable Workload Identity Federation on GCP"
}

resource "tfe_variable" "tfc_gcp_workload_provider_name" {
  workspace_id = tfe_workspace.environment_workspace.id

  key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value    = var.google_workload_provider_name
  category = "env"

  description = "The workload provider name to authenticate against on GCP"
}

resource "tfe_variable" "tfc_gcp_service_account_email" {
  workspace_id = tfe_workspace.environment_workspace.id

  key      = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value    = var.google_service_account_email
  category = "env"

  description = "The GCP service account email runs will use to authenticate"
}
