module "sentry" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "govuk-sentry"
  workspace_desc      = "This module manages user access to Sentry"
  workspace_tags      = ["sentry"]
  assessments_enabled = true
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/sentry/"
  trigger_patterns    = ["/terraform/deployments/sentry/**/*"]

  project_name = "govuk-sentry"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }
}

resource "tfe_project" "sentry" {
  name = "govuk-sentry"
}