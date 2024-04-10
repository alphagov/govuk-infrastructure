module "vpc-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.9.0"

  organization      = var.organization
  workspace_name    = "vpc-integration"
  workspace_desc    = "The vpc module is responsible for the AWS resources which constitute the EKS cluster."
  workspace_tags    = ["integration", "vpc", "eks", "aws"]
  terraform_version = "1.7.0"
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/vpc/"
  trigger_patterns  = ["/terraform/deployments/vpc/**/*"]
  global_remote_state = true

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

module "vpc-staging" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.9.0"

  organization      = var.organization
  workspace_name    = "vpc-staging"
  workspace_desc    = "The vpc module is responsible for the AWS resources which constitute the EKS cluster."
  workspace_tags    = ["staging", "vpc", "eks", "aws"]
  terraform_version = "1.7.0"
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/vpc/"
  trigger_patterns  = ["/terraform/deployments/vpc/**/*"]
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
    "aws-credentials-staging",
    "common",
    "common-staging"
  ]
}

module "vpc-production" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.9.0"

  organization      = var.organization
  workspace_name    = "vpc-production"
  workspace_desc    = "The vpc module is responsible for the AWS resources which constitute the EKS cluster."
  workspace_tags    = ["production", "vpc", "eks", "aws"]
  terraform_version = "1.7.0"
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/vpc/"
  trigger_patterns  = ["/terraform/deployments/vpc/**/*"]
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
    "aws-credentials-production",
    "common",
    "common-production"
  ]
}
