module "rds-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization      = var.organization
  workspace_name    = "rds-integration"
  workspace_desc    = "This module manages AWS resources for creating RDS databases."
  workspace_tags    = ["integration", "rds", "eks", "aws"]
  terraform_version = var.terraform_version
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
  version = "0.10.0"

  organization      = var.organization
  workspace_name    = "rds-staging"
  workspace_desc    = "This module manages AWS resources for creating RDS databases."
  workspace_tags    = ["staging", "rds", "eks", "aws"]
  terraform_version = var.terraform_version
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
    "GOV.UK Production" = "write"
  }

  variable_set_names = [
    "aws-credentials-staging",
    "common",
    "common-staging",
    "rds-staging"
  ]
}

module "rds-production" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization      = var.organization
  workspace_name    = "rds-production"
  workspace_desc    = "This module manages AWS resources for creating RDS databases."
  workspace_tags    = ["production", "rds", "eks", "aws"]
  terraform_version = var.terraform_version
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
    "GOV.UK Production" = "write"
  }

  variable_set_names = [
    "aws-credentials-production",
    "common",
    "common-production",
    "rds-production"
  ]
}
