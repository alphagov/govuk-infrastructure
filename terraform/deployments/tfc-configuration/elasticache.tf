module "elasticache-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "elasticache-integration"
  workspace_desc    = "Serverless ElastiCache instances"
  workspace_tags    = ["integration", "elasticache", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/elasticache/"
  trigger_patterns = [
    "/terraform/deployments/elasticache/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/integration/elasticache.tfvars"
  ]
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

  tfvars_files = [
    "integration/common.tfvars",
    "integration/elasticache.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}

module "elasticache-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "elasticache-staging"
  workspace_desc    = "Serverless ElastiCache instances"
  workspace_tags    = ["staging", "elasticache", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/elasticache/"
  trigger_patterns = [
    "/terraform/deployments/elasticache/**/*",
    "/terraform/variables/staging/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/staging/elasticache.tfvars"
  ]
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

  tfvars_files = [
    "staging/common.tfvars",
    "staging/elasticache.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["staging"]
  ]
}

module "elasticache-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "elasticache-production"
  workspace_desc    = "Serverless ElastiCache instances"
  workspace_tags    = ["production", "elasticache", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/elasticache/"
  trigger_patterns = [
    "/terraform/deployments/elasticache/**/*",
    "/terraform/variables/production/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/production/elasticache.tfvars"
  ]
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

  tfvars_files = [
    "production/common.tfvars",
    "production/elasticache.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["production"]
  ]
}
