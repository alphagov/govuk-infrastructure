module "mobile-backend-production" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "mobile-backend-production"
  workspace_desc      = "Infrastucture for GOV.UK App"
  workspace_tags      = ["production", "mobile-backend", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/mobile-backend/"
  trigger_patterns    = ["/terraform/deployments/mobile-backend/**/*"]
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
    module.variable-set-production.id
  ]
}

module "mobile-backend-staging" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "mobile-backend-staging"
  workspace_desc      = "Infrastucture for GOV.UK App"
  workspace_tags      = ["staging", "mobile-backend", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/mobile-backend/"
  trigger_patterns    = ["/terraform/deployments/mobile-backend/**/*"]
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
    module.variable-set-staging.id
  ]
}

module "mobile-backend-integration" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "mobile-backend-integration"
  workspace_desc      = "Infrastucture for GOV.UK App"
  workspace_tags      = ["integration", "mobile-backend", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/mobile-backend/"
  trigger_patterns    = ["/terraform/deployments/mobile-backend/**/*"]
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
    module.variable-set-integration.id
  ]
}

