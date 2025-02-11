module "csp-reporter-integration" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "csp-reporter-integration"
  workspace_desc    = "CSP reporter lambda and Firehose resources"
  workspace_tags    = ["integration", "csp-reporter", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/csp-reporter/"
  trigger_patterns  = ["/terraform/deployments/csp-reporter/**/*"]

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
    module.variable-set-common.id,
    module.variable-set-integration.id
  ]
}

module "csp-reporter-staging" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "csp-reporter-staging"
  workspace_desc    = "CSP reporter lambda and Firehose resources"
  workspace_tags    = ["staging", "csp-reporter", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/csp-reporter/"
  trigger_patterns  = ["/terraform/deployments/csp-reporter/**/*"]

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
    module.variable-set-common.id,
    module.variable-set-staging.id
  ]
}

module "csp-reporter-production" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "csp-reporter-production"
  workspace_desc    = "CSP reporter lambda and Firehose resources"
  workspace_tags    = ["production", "csp-reporter", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/csp-reporter/"
  trigger_patterns  = ["/terraform/deployments/csp-reporter/**/*"]

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
    module.variable-set-common.id,
    module.variable-set-production.id
  ]
}
