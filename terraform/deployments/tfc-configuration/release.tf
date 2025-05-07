module "release-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "release-production"
  workspace_desc      = "Manages IAM roles and policies for the Release app"
  workspace_tags      = ["production", "release", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/release/"
  trigger_patterns    = ["/terraform/deployments/release/**/*"]
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

  variable_set_ids = [
    local.aws_credentials["production"],
    module.variable-set-common.id,
    module.variable-set-production.id
  ]
}
