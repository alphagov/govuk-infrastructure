moved {
  from = module.elasticsearch-integration
  to   = module.service-linked-roles-integration
}

module "service-linked-roles-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "service-linked-roles-integration"
  workspace_desc    = "This module manages AWS Service Linked Roles for an account."
  workspace_tags    = ["integration", "service-linked-roles", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/service-linked-roles/"
  trigger_patterns = [
    "/terraform/deployments/service-linked-roles/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/integration/service-linked-roles.tfvars",
    "/terraform/shared-modules/s3/**/*",
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
    "integration/service-linked-roles.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}

moved {
  from = module.elasticsearch-staging
  to   = module.service-linked-roles-staging
}

module "service-linked-roles-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "service-linked-roles-staging"
  workspace_desc    = "This module manages AWS Service Linked Roles for an account."
  workspace_tags    = ["staging", "service-linked-roles", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/service-linked-roles/"
  trigger_patterns = [
    "/terraform/deployments/service-linked-roles/**/*",
    "/terraform/variables/staging/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/staging/service-linked-roles.tfvars",
    "/terraform/shared-modules/s3/**/*",
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
    "staging/service-linked-roles.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["staging"]
  ]
}

moved {
  from = module.elasticsearch-production
  to   = module.service-linked-roles-production
}

module "service-linked-roles-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "service-linked-roles-production"
  workspace_desc    = "This module manages AWS Service Linked Roles for an account."
  workspace_tags    = ["production", "service-linked-roles", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/service-linked-roles/"
  trigger_patterns = [
    "/terraform/deployments/service-linked-roles/**/*",
    "/terraform/variables/production/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/production/service-linked-roles.tfvars",
    "/terraform/shared-modules/s3/**/*",
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
    "production/service-linked-roles.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["production"]
  ]
}
