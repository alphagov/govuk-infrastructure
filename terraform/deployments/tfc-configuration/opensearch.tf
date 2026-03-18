module "opensearch-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "opensearch-integration"
  workspace_desc    = "This module manages AWS resources for creating OpenSearch cluster."
  workspace_tags    = ["integration", "opensearch", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/opensearch/"
  trigger_patterns = [
    "/terraform/deployments/opensearch/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/integration/opensearch.tfvars"
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
    "integration/opensearch.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}

module "opensearch-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "opensearch-staging"
  workspace_desc    = "This module manages AWS resources for creating OpenSearch cluster."
  workspace_tags    = ["staging", "opensearch", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/opensearch/"
  trigger_patterns = [
    "/terraform/deployments/opensearch/**/*",
    "/terraform/variables/staging/common.tfvars",
    "/terraform/variables/staging/opensearch.tfvars"
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
    "staging/opensearch.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["staging"]
  ]
}

module "opensearch-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "opensearch-production"
  workspace_desc    = "This module manages AWS resources for creating OpenSearch cluster."
  workspace_tags    = ["production", "opensearch", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/opensearch/"
  trigger_patterns = [
    "/terraform/deployments/opensearch/**/*",
    "/terraform/variables/production/common.tfvars",
    "/terraform/variables/production/opensearch.tfvars"
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
    "production/opensearch.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["production"]
  ]
}
