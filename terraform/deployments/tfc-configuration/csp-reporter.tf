module "csp-reporter-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.12.0"

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

  variable_set_names = [
    "aws-credentials-integration",
    module.variable-set-common.name,
    module.variable-set-integration.name
  ]
}

module "csp-reporter-staging" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.12.0"

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

  variable_set_names = [
    "aws-credentials-staging",
    module.variable-set-common.name,
    module.variable-set-staging.name
  ]
}

module "csp-reporter-production" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.12.0"

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

  variable_set_names = [
    "aws-credentials-production",
    module.variable-set-common.name,
    module.variable-set-production.name
  ]
}
