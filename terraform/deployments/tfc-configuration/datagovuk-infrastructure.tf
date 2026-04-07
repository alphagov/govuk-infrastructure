module "datagovuk-infrastructure-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "datagovuk-infrastructure-integration"
  workspace_desc    = "This module manages resources to run data.gov.uk on the GOV.UK EKS cluster"
  workspace_tags    = ["integration", "datagovuk-infrastructure", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/datagovuk-infrastructure/"
  trigger_patterns = [
    "/terraform/deployments/datagovuk-infrastructure/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/integration/datagovuk-infrastructure.tfvars"
  ]

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
    "integration/datagovuk-infrastructure.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}

module "datagovuk-infrastructure-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "datagovuk-infrastructure-staging"
  workspace_desc    = "This module manages resources to run data.gov.uk on the GOV.UK EKS cluster"
  workspace_tags    = ["staging", "datagovuk-infrastructure", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/datagovuk-infrastructure/"
  trigger_patterns = [
    "/terraform/deployments/datagovuk-infrastructure/**/*",
    "/terraform/variables/staging/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/staging/datagovuk-infrastructure.tfvars"
  ]

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
    "staging/datagovuk-infrastructure.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["staging"]
  ]
}

module "datagovuk-infrastructure-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "datagovuk-infrastructure-production"
  workspace_desc    = "This module manages resources to run data.gov.uk on the GOV.UK EKS cluster"
  workspace_tags    = ["production", "datagovuk-infrastructure", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/datagovuk-infrastructure/"
  trigger_patterns = [
    "/terraform/deployments/datagovuk-infrastructure/**/*",
    "/terraform/variables/production/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/production/datagovuk-infrastructure.tfvars"
  ]

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
    "production/datagovuk-infrastructure.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["production"]
  ]
}
