module "github" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "GitHub"
  workspace_desc      = "This module creates and manages GitHub repositories"
  workspace_tags      = ["github"]
  assessments_enabled = true
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/github/"
  trigger_patterns    = ["/terraform/deployments/github/**/*"]

  project_name = "govuk-github"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_ids = [
    local.aws_credentials["tools"],
  ]
}

resource "tfe_project" "github" {
  name = "govuk-github"
}