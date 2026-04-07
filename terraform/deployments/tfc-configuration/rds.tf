module "rds-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "rds-integration"
  workspace_desc    = "This module manages AWS resources for creating RDS databases."
  workspace_tags    = ["integration", "rds", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/rds/"
  trigger_patterns = [
    "/terraform/deployments/rds/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/integration/rds.tfvars",
    "/terraform/shared-modules/s3/**/*",
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

  envvars = {
    TF_CLI_ARGS_plan  = "-parallelism=30"
    TF_CLI_ARGS_apply = "-parallelism=30"
  }

  tfvars_files = [
    "integration/common.tfvars",
    "integration/rds.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}

module "rds-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "rds-staging"
  workspace_desc    = "This module manages AWS resources for creating RDS databases."
  workspace_tags    = ["staging", "rds", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/rds/"
  trigger_patterns = [
    "/terraform/deployments/rds/**/*",
    "/terraform/variables/staging/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/staging/rds.tfvars",
    "/terraform/shared-modules/s3/**/*",
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

  envvars = {
    TF_CLI_ARGS_plan  = "-parallelism=30"
    TF_CLI_ARGS_apply = "-parallelism=30"
  }

  tfvars_files = [
    "staging/common.tfvars",
    "staging/rds.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["staging"]
  ]
}

module "rds-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "rds-production"
  workspace_desc    = "This module manages AWS resources for creating RDS databases."
  workspace_tags    = ["production", "rds", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/rds/"
  trigger_patterns = [
    "/terraform/deployments/rds/**/*",
    "/terraform/variables/production/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/production/rds.tfvars",
    "/terraform/shared-modules/s3/**/*",
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

  envvars = {
    TF_CLI_ARGS_plan  = "-parallelism=30"
    TF_CLI_ARGS_apply = "-parallelism=30"
  }

  tfvars_files = [
    "production/common.tfvars",
    "production/rds.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["production"]
  ]
}
