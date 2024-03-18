module "ecr-production" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization        = var.organization
  workspace_name      = "ecr-production"
  workspace_desc      = "The ecr module is responsible for the AWS resources which constitute the EKS cluster."
  workspace_tags      = ["production", "ecr", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/ecr/"
  trigger_patterns    = ["/terraform/deployments/ecr/**/*"]
  global_remote_state = true

  project_name = "govuk-infrastructure"

  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }
  team_access = { "GOV.UK Production" = "write" }

  variable_set_names = [
    "aws-credentials-production",
    "common",
    "common-production",
    "ecr-production"
  ]
}
