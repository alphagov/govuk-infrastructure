module "govuk-app-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  project_name = "govuk-mobile-backend"
  vcs_repo = {
    identifier     = "alphagov/govuk-mobile-backend"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  organization        = var.organization
  workspace_name      = "govuk-app-integration"
  workspace_desc      = "This module manages provisioning of resources for the GOV.UK App mobile backend"
  workspace_tags      = ["integration", "govuk-app", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/"
  trigger_patterns    = ["/terraform/**/*"]
  global_remote_state = true

  team_access = {
    "GOV.UK Non-Production" = "write"
    "GOV.UK Production"     = "write"
  }

  variable_set_names = [
    "aws-credentials-integration",
    "common",
    "common-integration"
    // currently there are no tfvars needed for the app backend but can add a reference to them here when needed
  ]
}
