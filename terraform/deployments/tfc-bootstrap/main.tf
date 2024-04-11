resource "tfe_workspace" "tfc_bootstrap" {
  name              = "tfc-bootstrap"
  description       = "The tfc-bootsrap module is responsible for initialising teraform cloud."
  working_directory = "/terraform/deployments/tfc-bootstrap/"
  trigger_patterns  = ["/terraform/deployments/tfc-bootstrap/**/*"]
  execution_mode    = "local"
  vcs_repo {
    identifier     = "alphagov/govuk-infrastructure"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }
}

resource "tfe_project" "tfc_configuration" {
  name = "tfc-configuration"
}

module "tfc-configuration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization      = var.organization
  workspace_name    = "tfc-configuration"
  workspace_desc    = "This workspace is used to create other workspaces in terraform cloud"
  workspace_tags    = ["tfc", "configuration"]
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/tfc-configuration/"
  trigger_patterns  = ["/terraform/deployments/tfc-configuration/**/*"]

  project_name = "tfc-configuration"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }
  team_access = {
    "GOV.UK Senior Tech" = "admin",
    "GOV.UK Production"  = "write"
  }
}
