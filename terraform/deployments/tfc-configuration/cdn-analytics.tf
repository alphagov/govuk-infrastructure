module "cdn-analytics-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization        = var.organization
  workspace_name      = "cdn-analytics-integration"
  workspace_desc      = "BigQuery infrastructure for Data Insight & Analytics"
  workspace_tags      = ["integration", "cdn-analytics", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/cdn-analytics/"
  trigger_patterns    = ["/terraform/deployments/cdn-analytics/**/*"]
  global_remote_state = true

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Non-Production" = "write"
    "GOV.UK Production"     = "write"
  }

  variable_set_names = [
    "gcp-credentials-integration",
    "common",
    "common-integration"
  ]
}

module "cdn-analytics-staging" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization        = var.organization
  workspace_name      = "cdn-analytics-staging"
  workspace_desc      = "BigQuery infrastructure for Data Insight & Analytics"
  workspace_tags      = ["staging", "cdn-analytics", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/cdn-analytics/"
  trigger_patterns    = ["/terraform/deployments/cdn-analytics/**/*"]
  global_remote_state = true

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_names = [
    "gcp-credentials-staging",
    "common",
    "common-staging"
  ]
}

module "cdn-analytics-production" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization        = var.organization
  workspace_name      = "cdn-analytics-production"
  workspace_desc      = "BigQuery infrastructure for Data Insight & Analytics"
  workspace_tags      = ["production", "cdn-analytics", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/cdn-analytics/"
  trigger_patterns    = ["/terraform/deployments/cdn-analytics/**/*"]
  global_remote_state = true

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_names = [
    "gcp-credentials-production",
    "common",
    "common-production"
  ]
}