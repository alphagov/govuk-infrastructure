module "release-assumer-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "release-assumer-production"
  workspace_desc      = "Manages the release-assumer IAM role and policies"
  workspace_tags      = ["production", "release-assumer", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/release-assumer/"
  trigger_patterns    = ["/terraform/deployments/release-assumer/**/*"]
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
