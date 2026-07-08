moved {
  from = module.opensearch-integration
  to   = module.chat-opensearch-integration
}

module "chat-opensearch-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "chat-opensearch-integration"
  workspace_desc    = "This module manages AWS resources for creating the chat OpenSearch cluster."
  workspace_tags    = ["integration", "chat-opensearch", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/chat-opensearch/"
  trigger_patterns = [
    "/terraform/deployments/chat-opensearch/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/integration/chat-opensearch.tfvars",
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
    "integration/chat-opensearch.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}

moved {
  from = module.opensearch-staging
  to   = module.chat-opensearch-staging
}

module "chat-opensearch-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "chat-opensearch-staging"
  workspace_desc    = "This module manages AWS resources for creating the chat OpenSearch cluster."
  workspace_tags    = ["staging", "chat-opensearch", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/chat-opensearch/"
  trigger_patterns = [
    "/terraform/deployments/chat-opensearch/**/*",
    "/terraform/variables/staging/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/staging/chat-opensearch.tfvars",
    "/terraform/shared-modules/s3/**/*",
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
    "staging/chat-opensearch.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["staging"]
  ]
}

moved {
  from = module.opensearch-production
  to   = module.chat-opensearch-production
}

module "chat-opensearch-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "chat-opensearch-production"
  workspace_desc    = "This module manages AWS resources for creating the chat OpenSearch cluster."
  workspace_tags    = ["production", "chat-opensearch", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/chat-opensearch/"
  trigger_patterns = [
    "/terraform/deployments/chat-opensearch/**/*",
    "/terraform/variables/production/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/production/chat-opensearch.tfvars",
    "/terraform/shared-modules/s3/**/*",
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
    "production/chat-opensearch.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["production"]
  ]
}
