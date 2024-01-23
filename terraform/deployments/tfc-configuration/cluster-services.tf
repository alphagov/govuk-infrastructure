module "cluster-services-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.9.0"

  organization      = var.organization
  workspace_name    = "cluster-services-integration"
  workspace_desc    = "The cluster-services module is responsible for the AWS resources which constitute the EKS cluster."
  workspace_tags    = ["integration", "cluster-services", "eks", "aws"]
  terraform_version = "1.5.2"
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
    "GOV.UK Non-Production" = "write"
    "GOV.UK Production"     = "write"
  }

  variable_set_names = [
    "aws-credentials-integration",
    "common",
    "common-integration"
  ]
}

module "cluster-services-staging" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.9.0"

  organization      = var.organization
  workspace_name    = "cluster-services-staging"
  workspace_desc    = "The cluster-services module is responsible for the AWS resources which constitute the EKS cluster."
  workspace_tags    = ["staging", "cluster-services", "eks", "aws"]
  terraform_version = "1.5.2"
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
    "GOV.UK Non-Production" = "write"
    "GOV.UK Production"     = "write"
  }

  variable_set_names = [
    "aws-credentials-staging",
    "common",
    "common-staging"
  ]
}
