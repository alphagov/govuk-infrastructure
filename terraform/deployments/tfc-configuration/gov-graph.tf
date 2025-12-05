resource "tfe_project" "data-engineering-project" {
  name = "govuk-data-engineering"
}

module "gov-graph-dev" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "gov-graph-dev"
  workspace_desc    = "This module manages GCP resources for gov-graph."
  workspace_tags    = ["dev", "gov-graph", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/gcp-gov-graph/"
  trigger_patterns  = ["/terraform/deployments/gcp-gov-graph/**/*"]

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Non-Production (r/o)" = "write"
    "GOV.UK Production"           = "write"
  }

  variable_set_ids = [
    local.aws_credentials["integration"],
    module.variable-set-common.id,
    module.variable-set-integration.id,
    module.variable-set-gov-graph-dev.id
  ]

  depends_on = [tfe_project.data-engineering-project]
}

module "gov-graph-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "gov-graph-staging"
  workspace_desc    = "This module manages GCP resources for gov-graph."
  workspace_tags    = ["staging", "gov-graph", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/gcp-gov-graph/"
  trigger_patterns  = ["/terraform/deployments/gcp-gov-graph/**/*"]

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Non-Production (r/o)" = "write"
    "GOV.UK Production"           = "write"
  }

  variable_set_ids = [
    local.aws_credentials["staging"],
    module.variable-set-common.id,
    module.variable-set-staging.id,
    module.variable-set-gov-graph-staging.id
  ]

  depends_on = [tfe_project.data-engineering-project]
}

module "gov-graph-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "gov-graph-production"
  workspace_desc    = "This module manages GCP resources for gov-graph."
  workspace_tags    = ["production", "gov-graph", "gcp"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/gcp-gov-graph/"
  trigger_patterns  = ["/terraform/deployments/gcp-gov-graph/**/*"]

  project_name = "govuk-data-engineering"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Non-Production (r/o)" = "write"
    "GOV.UK Production"           = "write"
  }

  variable_set_ids = [
    local.aws_credentials["production"],
    module.variable-set-common.id,
    module.variable-set-production.id,
    module.variable-set-gov-graph-production.id
  ]

  depends_on = [tfe_project.data-engineering-project]
}