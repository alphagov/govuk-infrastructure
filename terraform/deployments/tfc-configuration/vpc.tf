module "vpc-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "vpc-integration"
  workspace_desc      = "This module manages foundational cloud resources that are required by most other modules (VPC)"
  workspace_tags      = ["integration", "vpc", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/vpc/"
  trigger_patterns    = ["/terraform/deployments/vpc/**/*"]
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

  variable_set_ids = [
    local.aws_credentials["integration"],
    local.gcp_credentials["integration"],
    module.variable-set-common.id,
    module.variable-set-integration.id
  ]
}

module "vpc-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "vpc-staging"
  workspace_desc      = "This module manages foundational cloud resources that are required by most other modules (VPC)"
  workspace_tags      = ["staging", "vpc", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/vpc/"
  trigger_patterns    = ["/terraform/deployments/vpc/**/*"]
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
    local.aws_credentials["staging"],
    local.gcp_credentials["staging"],
    module.variable-set-common.id,
    module.variable-set-staging.id
  ]
}

module "vpc-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "vpc-production"
  workspace_desc      = "This module manages foundational cloud resources that are required by most other modules (VPC)"
  workspace_tags      = ["production", "vpc", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/vpc/"
  trigger_patterns    = ["/terraform/deployments/vpc/**/*"]
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
    local.gcp_credentials["production"],
    module.variable-set-common.id,
    module.variable-set-production.id
  ]
}

module "vpc-ephemeral" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "vpc-ephemeral"
  workspace_desc      = "This module manages foundational cloud resources that are required by most other modules (VPC)"
  workspace_tags      = ["ephemeral", "vpc", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/vpc/"
  trigger_patterns    = ["/terraform/deployments/vpc/**/*"]
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
    local.aws_credentials["test"],
    local.gcp_credentials["test"],
    module.variable-set-common.id,
    module.variable-set-ephemeral.id
  ]
}
