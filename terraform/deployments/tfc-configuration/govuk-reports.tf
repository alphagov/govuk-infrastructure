module "govuk-reports-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "govuk-reports-integration"
  workspace_desc    = "This module manages the IAM resources needed for the govuk-reports prototype application"
  workspace_tags    = ["integration", "govuk-reports", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/govuk-reports/"
  trigger_patterns = [
    "/terraform/deployments/govuk-reports/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/integration/govuk-reports.tfvars"
  ]
  global_remote_state = true

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

  tfvars_files = [
    "integration/common.tfvars",
    "integration/govuk-reports.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}

