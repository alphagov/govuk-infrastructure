module "datagovuk-infrastructure-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

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
    module.variable-set-common.name,
    module.variable-set-integration.name
  ]

  variable_set_ids = [
    module.variable-set-common.id,
    module.variable-set-integration.id
  ]
}

module "datagovuk-infrastructure-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

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
    "aws-credentials-staging"
  ]

  variable_set_ids = [
    module.variable-set-common.id,
    module.variable-set-staging.id
  ]
}

module "datagovuk-infrastructure-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

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
    "aws-credentials-production"
  ]

  variable_set_ids = [
    module.variable-set-common.id,
    module.variable-set-production.id
  ]
}
