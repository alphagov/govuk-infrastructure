module "logging-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "logging-integration"
  workspace_desc    = "This module manages foundational cloud resources that are required by most other modules (VPC, DNS zones)"
  workspace_tags    = ["integration", "logging", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/logging/"
  trigger_patterns = [
    "/terraform/deployments/logging/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/integration/logging.tfvars"
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
    "integration/logging.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"],
    local.gcp_credentials["integration"]
  ]
}

module "logging-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "logging-staging"
  workspace_desc    = "VPC-level logging (flow logs, buckets, etc)"
  workspace_tags    = ["staging", "logging", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/logging/"
  trigger_patterns = [
    "/terraform/deployments/logging/**/*",
    "/terraform/variables/staging/common.tfvars",
    "/terraform/variables/staging/logging.tfvars"
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
    "staging/logging.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["staging"],
    local.gcp_credentials["staging"]
  ]
}

module "logging-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "logging-production"
  workspace_desc    = "VPC-level logging (flow logs, buckets, etc)"
  workspace_tags    = ["production", "logging", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/logging/"
  trigger_patterns = [
    "/terraform/deployments/logging/**/*",
    "/terraform/variables/production/common.tfvars",
    "/terraform/variables/production/logging.tfvars"
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
    "production/logging.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["production"],
    local.gcp_credentials["production"]
  ]
}

