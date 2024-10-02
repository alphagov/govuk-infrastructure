module "fastly-logs-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization        = var.organization
  workspace_name      = "fastly-logs-integration"
  workspace_desc      = "This module manages the Fastly logging data which is sent from Fastly to S3."
  workspace_tags      = ["integration", "fastly-logs", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/fastly-logs/"
  trigger_patterns    = ["/terraform/deployments/fastly-logs/**/*"]
  global_remote_state = true

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "fastly-logs"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Non-Production" = "write"
    "GOV.UK Production"     = "write"
  }

  variable_set_names = [
    "aws-credentials-integration",
    "common",
    "common-integration"
  ]
}

module "fastly-logs-staging" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization        = var.organization
  workspace_name      = "fastly-logs-staging"
  workspace_desc      = "This module manages the Fastly logging data which is sent from Fastly to S3."
  workspace_tags      = ["staging", "fastly-logs", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/fastly-logs/"
  trigger_patterns    = ["/terraform/deployments/fastly-logs/**/*"]
  global_remote_state = true

  project_name = "govuk-infrastructure"

  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "fastly-logs"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_names = [
    "aws-credentials-staging",
    "common",
    "common-staging"
  ]
}

module "fastly-logs-production" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization        = var.organization
  workspace_name      = "fastly-logs-production"
  workspace_desc      = "This module manages the Fastly logging data which is sent from Fastly to S3."
  workspace_tags      = ["production", "fastly-logs", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/fastly-logs/"
  trigger_patterns    = ["/terraform/deployments/fastly-logs/**/*"]
  global_remote_state = true

  project_name = "govuk-infrastructure"

  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "fastly-logs"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }
  team_access = { "GOV.UK Production" = "write" }

  variable_set_names = [
    "aws-credentials-production",
    "common",
    "common-production"
  ]
}
