module "opensearch-integration" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "opensearch-integration"
  workspace_desc    = "This module manages AWS resources for creating OpenSearch cluster."
  workspace_tags    = ["integration", "cluster-services", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/opensearch/"
  trigger_patterns  = ["/terraform/deployments/opensearch/**/*"]

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
    module.variable-set-integration.id,
    module.variable-set-opensearch-integration.id
  ]
}

module "opensearch-staging" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "opensearch-staging"
  workspace_desc    = "This module manages AWS resources for creating OpenSearch cluster."
  workspace_tags    = ["staging", "chat", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/opensearch/"
  trigger_patterns  = ["/terraform/deployments/opensearch/**/*"]

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
    module.variable-set-staging.id,
    module.variable-set-opensearch-staging.id
  ]
}

module "opensearch-production" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "opensearch-production"
  workspace_desc    = "This module manages AWS resources for creating OpenSearch cluster."
  workspace_tags    = ["production", "chat", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/opensearch/"
  trigger_patterns  = ["/terraform/deployments/opensearch/**/*"]

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
    "aws-credentials-production"
  ]

  variable_set_ids = [
    module.variable-set-common.id,
    module.variable-set-production.id,
    module.variable-set-opensearch-production.id
  ]
}
