module "govuk-publishing-infrastructure-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization      = var.organization
  workspace_name    = "govuk-publishing-infrastructure-integration"
  workspace_desc    = "This module manages AWS resources which are specific to GOV.UK Publishing."
  workspace_tags    = ["integration", "govuk-publishing-infrastructure", "eks", "aws"]
  terraform_version = "1.7.0"
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/govuk-publishing-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/govuk-publishing-infrastructure/**/*"]

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
    "common-integration"
  ]
}

module "govuk-publishing-infrastructure-staging" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization      = var.organization
  workspace_name    = "govuk-publishing-infrastructure-staging"
  workspace_desc    = "This module manages AWS resources which are specific to GOV.UK Publishing."
  workspace_tags    = ["staging", "govuk-publishing-infrastructure", "eks", "aws"]
  terraform_version = "1.7.0"
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/govuk-publishing-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/govuk-publishing-infrastructure/**/*"]

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
    "common-staging"
  ]
}

module "govuk-publishing-infrastructure-production" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization      = var.organization
  workspace_name    = "govuk-publishing-infrastructure-production"
  workspace_desc    = "This module manages AWS resources which are specific to GOV.UK Publishing."
  workspace_tags    = ["production", "govuk-publishing-infrastructure", "eks", "aws"]
  terraform_version = "1.7.0"
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/govuk-publishing-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/govuk-publishing-infrastructure/**/*"]

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
    "common-production"
  ]
}
