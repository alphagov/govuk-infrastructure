module "elasticsearch-green-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "elasticsearch-green-integration"
  workspace_desc    = "This module manages AWS resources for creating an Elasticsearch cluster."
  workspace_tags    = ["integration", "elasticsearch", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/elasticsearch-green/"
  trigger_patterns = [
    "/terraform/deployments/elasticsearch-green/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/integration/elasticsearch-green.tfvars"
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
    "integration/elasticsearch-green.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}

module "elasticsearch-green-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "elasticsearch-green-staging"
  workspace_desc    = "This module manages AWS resources for creating an Elasticsearch cluster."
  workspace_tags    = ["staging", "elasticsearch", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/elasticsearch-green/"
  trigger_patterns = [
    "/terraform/deployments/elasticsearch-green/**/*",
    "/terraform/variables/staging/common.tfvars",
    "/terraform/variables/staging/elasticsearch-green.tfvars"
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
    "staging/elasticsearch-green.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["staging"]
  ]
}

module "elasticsearch-green-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "elasticsearch-green-production"
  workspace_desc    = "This module manages AWS resources for creating an Elasticsearch cluster."
  workspace_tags    = ["production", "elasticsearch", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/elasticsearch-green/"
  trigger_patterns = [
    "/terraform/deployments/elasticsearch-green/**/*",
    "/terraform/variables/production/common.tfvars",
    "/terraform/variables/production/elasticsearch-green.tfvars"
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
    "production/elasticsearch-green.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["production"]
  ]
}
