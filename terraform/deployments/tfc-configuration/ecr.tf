module "ecr-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "ecr-production"
  workspace_desc    = "This module manages Elastic Container Registry repositories, to store OCI images of GOV.UK apps"
  workspace_tags    = ["production", "ecr", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/ecr/"
  trigger_patterns = [
    "/terraform/deployments/ecr/**/*",
    "/terraform/variables/production/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/production/ecr.tfvars"
  ]
  global_remote_state = true

  project_name = "govuk-infrastructure"

  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }
  team_access = { "GOV.UK Production" = "write" }

  tfvars_files = [
    "production/common.tfvars",
    "production/ecr.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["production"]
  ]

  run_trigger_source_workspaces = ["GitHub"]
}
