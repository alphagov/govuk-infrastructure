module "govuk-publishing-infrastructure-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.9.0"

  organization      = var.organization
  workspace_name    = "govuk-publishing-infrastructure-integration"
  workspace_desc    = "This module manages AWS resources which are specific to GOV.UK Publishing."
  workspace_tags    = ["integration", "govuk-publishing-infrastructure", "eks", "aws"]
  terraform_version = "1.7.0"
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/govuk-publishing-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/govuk-publishing-infrastructure/**/*"]

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "samsimpson1/tfc"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Non-Production" = "write"
    "GOV.UK Production"     = "write"
  }

  variable_set_names = [
    "aws-credentials-integration",
    "common",
    "common-integration"
  ]
}
