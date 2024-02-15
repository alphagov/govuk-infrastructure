module "rds-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.9.0"

  organization      = var.organization
  workspace_name    = "rds-integration"
  workspace_desc    = "This module manages AWS resources for creating RDS databases."
  workspace_tags    = ["integration", "rds", "eks", "aws"]
  terraform_version = "1.7.0"
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/rds/"
  trigger_patterns  = ["/terraform/deployments/rds/**/*"]

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
    "aws-credentials-integration",
    "common",
    "common-integration",
    "rds-integration"
  ]
}

module "rds-staging" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.9.0"

  organization      = var.organization
  workspace_name    = "rds-staging"
  workspace_desc    = "This module manages AWS resources for creating RDS databases."
  workspace_tags    = ["staging", "rds", "eks", "aws"]
  terraform_version = "1.7.0"
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/rds/"
  trigger_patterns  = ["/terraform/deployments/rds/**/*"]

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "samsimpson1/rds"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_names = [
    "aws-credentials-staging",
    "common",
    "common-staging",
    "rds-staging"
  ]
}
