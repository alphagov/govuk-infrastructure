module "cloudfront-staging" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "cloudfront-staging"
  workspace_desc      = "This module manages resources for the failover CDN in Cloudfront"
  workspace_tags      = ["staging", "cloudfront", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/cloudfront/"
  trigger_patterns    = ["/terraform/deployments/cloudfront/**/*"]
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
    module.variable-set-common.id,
    module.variable-set-staging.id,
    module.variable-set-cloudfront-staging.id
  ]
}

module "cloudfront-production" {
  source = "github.com/alphagov/terraform-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "cloudfront-production"
  workspace_desc      = "This module manages resources for the failover CDN in Cloudfront"
  workspace_tags      = ["production", "cloudfront", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/cloudfront/"
  trigger_patterns    = ["/terraform/deployments/cloudfront/**/*"]
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
    module.variable-set-common.id,
    module.variable-set-production.id,
    module.variable-set-cloudfront-production.id
  ]
}
