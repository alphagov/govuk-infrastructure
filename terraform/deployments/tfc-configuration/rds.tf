module "rds-integration" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "rds-integration"
  workspace_desc      = "This module manages AWS resources for creating RDS databases."
  workspace_tags      = ["integration", "rds", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/rds/"
  trigger_patterns    = ["/terraform/deployments/rds/**/*"]
  global_remote_state = true

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
    "aws-credentials-integration"
  ]

  variable_set_ids = [
    module.variable-set-common.id,
    module.variable-set-integration.id,
    module.variable-set-rds-integration.id
  ]
}

module "rds-staging" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "rds-staging"
  workspace_desc      = "This module manages AWS resources for creating RDS databases."
  workspace_tags      = ["staging", "rds", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/rds/"
  trigger_patterns    = ["/terraform/deployments/rds/**/*"]
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
    "aws-credentials-staging"
  ]

  variable_set_ids = [
    module.variable-set-common.id,
    module.variable-set-staging.id,
    module.variable-set-rds-staging.id
  ]
}

module "rds-production" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "rds-production"
  workspace_desc      = "This module manages AWS resources for creating RDS databases."
  workspace_tags      = ["production", "rds", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/rds/"
  trigger_patterns    = ["/terraform/deployments/rds/**/*"]
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
    "aws-credentials-production"
  ]

  variable_set_ids = [
    module.variable-set-common.id,
    module.variable-set-production.id,
    module.variable-set-rds-production.id
  ]
}
