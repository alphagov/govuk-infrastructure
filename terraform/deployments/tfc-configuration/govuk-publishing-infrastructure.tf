module "govuk-publishing-infrastructure-integration" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "govuk-publishing-infrastructure-integration"
  workspace_desc    = "This module manages AWS resources which are specific to GOV.UK Publishing."
  workspace_tags    = ["integration", "govuk-publishing-infrastructure", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/govuk-publishing-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/govuk-publishing-infrastructure/**/*"]

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

  variable_set_ids = [
    local.aws_credentials["integration"],
    local.gcp_credentials["integration"],
    module.variable-set-common.id,
    module.variable-set-integration.id,
    module.variable-set-amazonmq-integration.id,
    module.sensitive-variables.waf_integration_id
  ]
}

module "govuk-publishing-infrastructure-staging" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "govuk-publishing-infrastructure-staging"
  workspace_desc    = "This module manages AWS resources which are specific to GOV.UK Publishing."
  workspace_tags    = ["staging", "govuk-publishing-infrastructure", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/govuk-publishing-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/govuk-publishing-infrastructure/**/*"]

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_ids = [
    local.aws_credentials["staging"],
    local.gcp_credentials["staging"],
    module.variable-set-common.id,
    module.variable-set-staging.id,
    module.variable-set-amazonmq-staging.id,
    module.sensitive-variables.waf_staging_id
  ]
}

module "govuk-publishing-infrastructure-production" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "govuk-publishing-infrastructure-production"
  workspace_desc    = "This module manages AWS resources which are specific to GOV.UK Publishing."
  workspace_tags    = ["production", "govuk-publishing-infrastructure", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/govuk-publishing-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/govuk-publishing-infrastructure/**/*"]

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_ids = [
    local.aws_credentials["production"],
    local.gcp_credentials["production"],
    module.variable-set-common.id,
    module.variable-set-production.id,
    module.variable-set-amazonmq-production.id,
    module.sensitive-variables.waf_production_id
  ]
}
