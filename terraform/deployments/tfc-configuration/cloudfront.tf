module "cloudfront-staging" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.9.0"

  organization        = var.organization
  workspace_name      = "cloudfront-staging"
  workspace_desc      = "The cloudfront module is responsible for the AWS resources which constitute the EKS cluster."
  workspace_tags      = ["staging", "cloudfront", "eks", "aws"]
  terraform_version   = "1.7.0"
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/cloudfront/"
  trigger_patterns    = ["/terraform/deployments/cloudfront/**/*"]
  global_remote_state = true

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "samsimpson1/tfc"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"     = "write"
  }

  variable_set_names = [
    "aws-credentials-staging",
    "common",
    "common-staging",
    "cloudfront-staging"
  ]
}
