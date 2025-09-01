module "cluster-access-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization           = var.organization
  workspace_name         = "cluster-access-integration"
  workspace_desc         = "This module manages user access to the EKS cluster"
  workspace_tags         = ["integration", "cluster-access", "eks", "aws"]
  terraform_version      = var.terraform_version
  auto_apply             = true
  auto_apply_run_trigger = true
  execution_mode         = "remote"
  working_directory      = "/terraform/deployments/cluster-access/"
  trigger_patterns       = ["/terraform/deployments/cluster-access/**/*"]

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
    module.variable-set-common.id,
    module.variable-set-integration.id
  ]

  run_trigger_source_workspaces = ["govuk-aws-users-integration"]
}

module "cluster-access-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization           = var.organization
  workspace_name         = "cluster-access-staging"
  workspace_desc         = "This module manages user access to the EKS cluster"
  workspace_tags         = ["staging", "cluster-access", "eks", "aws"]
  terraform_version      = var.terraform_version
  auto_apply             = true
  auto_apply_run_trigger = true
  execution_mode         = "remote"
  working_directory      = "/terraform/deployments/cluster-access/"
  trigger_patterns       = ["/terraform/deployments/cluster-access/**/*"]

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
    module.variable-set-common.id,
    module.variable-set-staging.id
  ]

  run_trigger_source_workspaces = ["govuk-aws-users-staging"]
}

module "cluster-access-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization           = var.organization
  workspace_name         = "cluster-access-production"
  workspace_desc         = "This module manages user access to the EKS cluster"
  workspace_tags         = ["production", "cluster-access", "eks", "aws"]
  terraform_version      = var.terraform_version
  auto_apply             = true
  auto_apply_run_trigger = true
  execution_mode         = "remote"
  working_directory      = "/terraform/deployments/cluster-access/"
  trigger_patterns       = ["/terraform/deployments/cluster-access/**/*"]

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

  run_trigger_source_workspaces = ["govuk-aws-users-production"]
}
