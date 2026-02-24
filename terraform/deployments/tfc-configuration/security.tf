module "security-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "security-integration"
  workspace_desc      = "This module manages AWS Security resources for use by other modules and resources."
  workspace_tags      = ["integration", "security", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/security/"
  trigger_patterns    = ["/terraform/deployments/security/**/*"]
  global_remote_state = true

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
    module.variable-set-integration.id,
    module.sensitive-variables.security_common_id,
    module.sensitive-variables.security_integration_id
  ]
}

module "security-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "security-staging"
  workspace_desc      = "This module manages AWS Security resources for use by other modules and resources."
  workspace_tags      = ["staging", "security", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/security/"
  trigger_patterns    = ["/terraform/deployments/security/**/*"]
  global_remote_state = true

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
    module.variable-set-staging.id,
    module.sensitive-variables.security_common_id,
    module.sensitive-variables.security_staging_id
  ]
}

module "security-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "security-production"
  workspace_desc      = "This module manages AWS Security resources for use by other modules and resources."
  workspace_tags      = ["production", "security", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/security/"
  trigger_patterns    = ["/terraform/deployments/security/**/*"]
  global_remote_state = true

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
    module.variable-set-production.id,
    module.sensitive-variables.security_common_id,
    module.sensitive-variables.security_production_id
  ]
}
