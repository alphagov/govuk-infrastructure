module "gcp-ga4-analytics" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-ga4-analytics"
  workspace_desc      = "GCP project management for the GA4 production project"
  workspace_tags      = ["production", "ga4-analytics", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/ga4-analytics/"
  trigger_patterns    = ["/terraform/deployments/ga4-analytics/**/*"]
  global_remote_state = true

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
    "GOV.UK Non-Production (r/o)"  = "read"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-ga4-aggregate-analytics" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-ga4-aggregate-analytics"
  workspace_desc      = "GCP project management for the ga4-aggregate-analytics production project"
  workspace_tags      = ["production", "ga4-aggregate-analytics", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-ga4-aggregate-analytics/"
  trigger_patterns    = ["/terraform/deployments/gcp-ga4-aggregate-analytics/**/*"]
  global_remote_state = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}

module "gcp-gds-bq-processing" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-gds-bq-processing"
  workspace_desc      = "GCP project management for the gds-bq-processing production project"
  workspace_tags      = ["production", "gds-bq-processing", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/gcp-gds-bq-processing/"
  trigger_patterns    = ["/terraform/deployments/gcp-gds-bq-processing/**/*"]
  global_remote_state = true

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}
