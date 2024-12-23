module "cluster-services-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization      = var.organization
  workspace_name    = "cluster-services-integration"
  workspace_desc    = "This module manages resources for services that run on top of the EKS cluster and are required by apps running on the cluster"
  workspace_tags    = ["integration", "cluster-services", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/cluster-services/"
  trigger_patterns  = ["/terraform/deployments/cluster-services/**/*"]

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
    "aws-credentials-integration",
    "common",
    "common-integration"
  ]
}

module "cluster-services-staging" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization      = var.organization
  workspace_name    = "cluster-services-staging"
  workspace_desc    = "This module manages resources for services that run on top of the EKS cluster and are required by apps running on the cluster"
  workspace_tags    = ["staging", "cluster-services", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/cluster-services/"
  trigger_patterns  = ["/terraform/deployments/cluster-services/**/*"]

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
    "aws-credentials-staging",
    "common",
    "common-staging"
  ]
}

module "cluster-services-production" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization      = var.organization
  workspace_name    = "cluster-services-production"
  workspace_desc    = "This module manages resources for services that run on top of the EKS cluster and are required by apps running on the cluster"
  workspace_tags    = ["production", "cluster-services", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/cluster-services/"
  trigger_patterns  = ["/terraform/deployments/cluster-services/**/*"]

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
    "aws-credentials-production",
    "common",
    "common-production"
  ]
}
