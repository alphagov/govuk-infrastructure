module "chat-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.12.0"

  organization        = var.organization
  workspace_name      = "chat-integration"
  workspace_desc      = "This module manages the resources needed to run GOV.UK chat"
  workspace_tags      = ["integration", "chat", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/chat/"
  trigger_patterns    = ["/terraform/deployments/chat/**/*"]
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
    module.variable-set-integration.name,
    module.variable-set-chat-integration.name
  ]
}

module "chat-staging" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.12.0"

  organization        = var.organization
  workspace_name      = "chat-staging"
  workspace_desc      = "This module manages the resources needed to run GOV.UK chat"
  workspace_tags      = ["staging", "chat", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/chat/"
  trigger_patterns    = ["/terraform/deployments/chat/**/*"]
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
    module.variable-set-staging.name,
    module.variable-set-chat-staging.name
  ]
}

module "chat-production" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.12.0"

  organization        = var.organization
  workspace_name      = "chat-production"
  workspace_desc      = "This module manages the resources needed to run GOV.UK chat"
  workspace_tags      = ["production", "chat", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/chat/"
  trigger_patterns    = ["/terraform/deployments/chat/**/*"]
  global_remote_state = true

  project_name = "govuk-infrastructure"

  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }
  team_access = { "GOV.UK Production" = "write" }

  variable_set_names = [
    "aws-credentials-production",
    module.variable-set-common.name,
    module.variable-set-production.name,
    module.variable-set-chat-production.name
  ]
}
