module "synthetic-test-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "synthetic-test-integration"
  workspace_desc    = "Manages IAM roles and policies for the Synthetic Test app"
  workspace_tags    = ["integration", "synthetic-test", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/synthetic-test/"
  trigger_patterns = [
    "/terraform/deployments/synthetic-test/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/integration/synthetic-test.tfvars"
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
    "integration/synthetic-test.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}

module "synthetic-test-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "synthetic-test-staging"
  workspace_desc    = "Manages IAM roles and policies for the Synthetic Test app"
  workspace_tags    = ["staging", "synthetic-test", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/synthetic-test/"
  trigger_patterns = [
    "/terraform/deployments/synthetic-test/**/*",
    "/terraform/variables/staging/common.tfvars",
    "/terraform/variables/staging/synthetic-test.tfvars"
  ]
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

  tfvars_files = [
    "staging/common.tfvars",
    "staging/synthetic-test.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["staging"]
  ]
}

module "synthetic-test-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "synthetic-test-production"
  workspace_desc    = "Manages IAM roles and policies for the Synthetic Test app"
  workspace_tags    = ["production", "synthetic-test", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/synthetic-test/"
  trigger_patterns = [
    "/terraform/deployments/synthetic-test/**/*",
    "/terraform/variables/production/common.tfvars",
    "/terraform/variables/production/synthetic-test.tfvars"
  ]
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

  tfvars_files = [
    "production/common.tfvars",
    "production/synthetic-test.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["production"]
  ]
}
