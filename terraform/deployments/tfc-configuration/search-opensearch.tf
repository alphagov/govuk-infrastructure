moved {
  from = module.elasticsearch-green-integration
  to   = module.search-opensearch-integration
}

module "search-opensearch-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "search-opensearch-integration"
  workspace_desc    = "This module manages AWS resources for creating the Search AWS OpenSearch blue and/or green clusters."
  workspace_tags    = ["integration", "search-opensearch", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/search-opensearch/"
  trigger_patterns = [
    "/terraform/deployments/search-opensearch/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/integration/search-opensearch.tfvars",
    "/terraform/shared-modules/s3/**/*",
    "/terraform/shared-modules/opensearch-blue-green-deployment/**/*",
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
    "integration/search-opensearch.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}

moved {
  from = module.elasticsearch-green-staging
  to   = module.search-opensearch-staging
}

module "search-opensearch-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "search-opensearch-staging"
  workspace_desc    = "This module manages AWS resources for creating the Search AWS OpenSearch blue and/or green clusters."
  workspace_tags    = ["staging", "search-opensearch", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/search-opensearch/"
  trigger_patterns = [
    "/terraform/deployments/search-opensearch/**/*",
    "/terraform/variables/staging/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/staging/search-opensearch.tfvars",
    "/terraform/shared-modules/s3/**/*",
    "/terraform/shared-modules/opensearch-blue-green-deployment/**/*",
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
    "staging/search-opensearch.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["staging"]
  ]
}

moved {
  from = module.elasticsearch-green-production
  to   = module.search-opensearch-production
}

module "search-opensearch-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "search-opensearch-production"
  workspace_desc    = "This module manages AWS resources for creating the Search AWS OpenSearch blue and/or green clusters."
  workspace_tags    = ["production", "search-opensearch", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/search-opensearch/"
  trigger_patterns = [
    "/terraform/deployments/search-opensearch/**/*",
    "/terraform/variables/production/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/production/search-opensearch.tfvars",
    "/terraform/shared-modules/s3/**/*",
    "/terraform/shared-modules/opensearch-blue-green-deployment/**/*",
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
    "production/search-opensearch.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["production"]
  ]
}
