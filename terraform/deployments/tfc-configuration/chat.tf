module "chat-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "chat-integration"
  workspace_desc    = "This module manages the resources needed to run GOV.UK chat"
  workspace_tags    = ["integration", "chat", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/chat/"
  trigger_patterns = [
    "/terraform/deployments/chat/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/integration/chat.tfvars"
  ]
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

  tfvars_files = [
    "integration/common.tfvars",
    "integration/chat.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}

module "chat-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "chat-staging"
  workspace_desc    = "This module manages the resources needed to run GOV.UK chat"
  workspace_tags    = ["staging", "chat", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/chat/"
  trigger_patterns = [
    "/terraform/deployments/chat/**/*",
    "/terraform/variables/staging/common.tfvars",
    "/terraform/variables/staging/chat.tfvars"
  ]
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

  tfvars_files = [
    "staging/common.tfvars",
    "staging/chat.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["staging"]
  ]
}

module "chat-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "chat-production"
  workspace_desc    = "This module manages the resources needed to run GOV.UK chat"
  workspace_tags    = ["production", "chat", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/chat/"
  trigger_patterns = [
    "/terraform/deployments/chat/**/*",
    "/terraform/variables/production/common.tfvars",
    "/terraform/variables/production/chat.tfvars"
  ]
  global_remote_state = true

  project_name = "govuk-infrastructure"

  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }
  team_access = { "GOV.UK Production" = "write" }

  tfvars_files = [
    "production/common.tfvars",
    "production/chat.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["production"]
  ]
}
