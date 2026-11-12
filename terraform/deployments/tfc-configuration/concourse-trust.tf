module "concourse-trust-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization   = var.organization
  workspace_name = "concourse-trust-integration"
  workspace_desc = "IAM roles with trust policies for Concourse"
  workspace_tags = ["integration", "concourse-trust", "iam", "aws"]
  terraform_version = var.terraform_version
  working_directory = "/terraform/deployments/concourse-trust"
  trigger_patterns = [
    "/terraform/deployments/concourse-trust/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/integration/concourse-trust.tfvars",
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
    "integration/concourse-trust.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}

module "concourse-trust-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization   = var.organization
  workspace_name = "concourse-trust-staging"
  workspace_desc = "IAM roles with trust policies for Concourse"
  workspace_tags = ["staging", "concourse-trust", "iam", "aws"]
  terraform_version = var.terraform_version
  working_directory = "/terraform/deployments/concourse-trust"
  trigger_patterns = [
    "/terraform/deployments/concourse-trust/**/*",
    "/terraform/variables/staging/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/staging/concourse-trust.tfvars",
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
    "staging/common.tfvars",
    "staging/concourse-trust.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["staging"]
  ]
}

module "concourse-trust-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization   = var.organization
  workspace_name = "concourse-trust-production"
  workspace_desc = "IAM roles with trust policies for Concourse"
  workspace_tags = ["production", "concourse-trust", "iam", "aws"]
  terraform_version = var.terraform_version
  working_directory = "/terraform/deployments/concourse-trust"
  trigger_patterns = [
    "/terraform/deployments/concourse-trust/**/*",
    "/terraform/variables/production/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/production/concourse-trust.tfvars",
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
    "production/common.tfvars",
    "production/concourse-trust.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["production"]
  ]
}