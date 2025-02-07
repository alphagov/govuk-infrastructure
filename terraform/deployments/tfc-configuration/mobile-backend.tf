module "mobile-backend-production" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.12.0"

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
    "aws-credentials-production",
    module.variable-set-common.name,
    module.variable-set-production.name
  ]
}

module "mobile-backend-staging" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.12.0"

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
    "aws-credentials-staging",
    module.variable-set-common.name,
    module.variable-set-staging.name
  ]
}

module "mobile-backend-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.12.0"

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
    "aws-credentials-integration",
    module.variable-set-common.name,
    module.variable-set-integration.name
  ]
}

