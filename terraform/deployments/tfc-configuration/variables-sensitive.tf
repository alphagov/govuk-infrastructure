module "variables-sensitive" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.12.0"

  organization        = var.organization
  workspace_name      = "variables-sensitive"
  workspace_desc      = "This module manages sensitive variables for Terraform Cloud workspaces."
  workspace_tags      = ["tfc", "variables", "sensitive"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/"
  trigger_patterns    = ["/**/*"]
  global_remote_state = true

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure-sensitive"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Non-Production (r/o)" = "read"
    "GOV.UK Production"           = "write"
  }
}
