module "chat-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

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
    "GOV.UK Non-Production" = "write"
    "GOV.UK Production"     = "write"
  }

  variable_set_names = [
    "aws-credentials-integration",
    "common",
    "common-integration",
    "chat-integration"
  ]
}

module "chat-staging" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

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
    "common",
    "common-staging",
    "chat-staging"
  ]
}

module "chat-production" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

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
    "common",
    "common-production",
    "chat-production"
  ]
}
