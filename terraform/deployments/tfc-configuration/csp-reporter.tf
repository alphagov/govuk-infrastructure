module "csp-reporter-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization      = var.organization
  workspace_name    = "csp-reporter-integration"
  workspace_desc    = "CSP reporter lambda and Firehose resources"
  workspace_tags    = ["integration", "csp-reporter", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/csp-reporter/"
  trigger_patterns  = ["/terraform/deployments/csp-reporter/**/*"]

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
    "common",
    "common-integration"
  ]
}
