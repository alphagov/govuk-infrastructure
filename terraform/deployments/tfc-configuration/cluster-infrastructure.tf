module "cluster-infrastructure-integration" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "cluster-infrastructure-integration"
  workspace_desc      = "This module manages the EKS cluster, and other resources it depends on (e.g. IAM roles and policies)"
  workspace_tags      = ["integration", "cluster-infrastructure", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/cluster-infrastructure/"
  trigger_patterns    = ["/terraform/deployments/cluster-infrastructure/**/*"]
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

  variable_set_names = [
    "aws-credentials-integration"
  ]

  variable_set_ids = [
    module.variable-set-common.id,
    module.variable-set-integration.id
  ]
}

module "cluster-infrastructure-staging" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "cluster-infrastructure-staging"
  workspace_desc      = "This module manages the EKS cluster, and other resources it depends on (e.g. IAM roles and policies)"
  workspace_tags      = ["staging", "cluster-infrastructure", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/cluster-infrastructure/"
  trigger_patterns    = ["/terraform/deployments/cluster-infrastructure/**/*"]
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

  variable_set_names = [
    "aws-credentials-staging"
  ]

  variable_set_ids = [
    module.variable-set-common.id,
    module.variable-set-staging.id
  ]
}

module "cluster-infrastructure-production" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "cluster-infrastructure-production"
  workspace_desc      = "This module manages the EKS cluster, and other resources it depends on (e.g. IAM roles and policies)"
  workspace_tags      = ["production", "cluster-infrastructure", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/cluster-infrastructure/"
  trigger_patterns    = ["/terraform/deployments/cluster-infrastructure/**/*"]
  global_remote_state = true

  project_name = "govuk-infrastructure"

  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }
  team_access = { "GOV.UK Production" = "write" }

  variable_set_names = [
    "aws-credentials-production"
  ]

  variable_set_ids = [
    module.variable-set-common.id,
    module.variable-set-production.id
  ]
}
