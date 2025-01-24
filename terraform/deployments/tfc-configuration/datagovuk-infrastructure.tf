module "datagovuk-infrastructure-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "~> 0.12.0"

  organization      = var.organization
  workspace_name    = "datagovuk-infrastructure-integration"
  workspace_desc    = "This module manages resources to run data.gov.uk on the GOV.UK EKS cluster"
  workspace_tags    = ["integration", "datagovuk-infrastructure", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/datagovuk-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/datagovuk-infrastructure/**/*"]

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Non-Production (r/o)" = "write"
    "GOV.UK Production"           = "write"
  }

  variable_set_names = [
    "aws-credentials-integration",
    "common",
    "common-integration"
  ]
}

module "datagovuk-infrastructure-staging" {
  source  = "alexbasista/workspacer/tfe"
  version = "~> 0.12.0"

  organization      = var.organization
  workspace_name    = "datagovuk-infrastructure-staging"
  workspace_desc    = "This module manages resources to run data.gov.uk on the GOV.UK EKS cluster"
  workspace_tags    = ["staging", "datagovuk-infrastructure", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/datagovuk-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/datagovuk-infrastructure/**/*"]

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

module "datagovuk-infrastructure-production" {
  source  = "alexbasista/workspacer/tfe"
  version = "~> 0.12.0"

  organization      = var.organization
  workspace_name    = "datagovuk-infrastructure-production"
  workspace_desc    = "This module manages resources to run data.gov.uk on the GOV.UK EKS cluster"
  workspace_tags    = ["production", "datagovuk-infrastructure", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/datagovuk-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/datagovuk-infrastructure/**/*"]

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
