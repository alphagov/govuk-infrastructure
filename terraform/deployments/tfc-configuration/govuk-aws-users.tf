module "govuk-aws-users-tools" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization           = var.organization
  workspace_name         = "govuk-aws-users-tools"
  workspace_desc         = "This manages the IAM roles and policies for the GOV.UK tools AWS account"
  workspace_tags         = ["user-management", "aws"]
  terraform_version      = var.terraform_version
  assessments_enabled    = true
  auto_apply             = true
  auto_apply_run_trigger = true
  execution_mode         = "remote"
  working_directory      = "/terraform/aws"
  trigger_patterns       = ["/terraform/aws/**/*", "/config/**/*"]

  project_name = "govuk-user-management"
  vcs_repo = {
    identifier     = "alphagov/govuk-user-reviewer"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"  = "read"
    "GOV.UK Senior Tech" = "write"
  }

  tfvars = {
    environment = "tools"
  }

  variable_set_ids = [
    local.aws_credentials["tools"]
  ]
}

module "govuk-aws-users-test" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization           = var.organization
  workspace_name         = "govuk-aws-users-test"
  workspace_desc         = "This manages the IAM roles and policies for the GOV.UK test AWS account"
  workspace_tags         = ["user-management", "aws"]
  terraform_version      = var.terraform_version
  assessments_enabled    = true
  auto_apply             = true
  auto_apply_run_trigger = true
  execution_mode         = "remote"
  working_directory      = "/terraform/aws"
  trigger_patterns       = ["/terraform/aws/**/*", "/config/**/*"]

  project_name = "govuk-user-management"
  vcs_repo = {
    identifier     = "alphagov/govuk-user-reviewer"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"  = "read"
    "GOV.UK Senior Tech" = "write"
  }

  tfvars = {
    environment = "test"
  }

  variable_set_ids = [
    local.aws_credentials["test"]
  ]
}

module "govuk-aws-users-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization           = var.organization
  workspace_name         = "govuk-aws-users-integration"
  workspace_desc         = "This manages the IAM roles and policies for the GOV.UK integration AWS account"
  workspace_tags         = ["user-management", "aws"]
  terraform_version      = var.terraform_version
  assessments_enabled    = true
  auto_apply             = true
  auto_apply_run_trigger = true
  execution_mode         = "remote"
  working_directory      = "/terraform/aws"
  trigger_patterns       = ["/terraform/aws/**/*", "/config/**/*"]

  project_name = "govuk-user-management"
  vcs_repo = {
    identifier     = "alphagov/govuk-user-reviewer"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"  = "read"
    "GOV.UK Senior Tech" = "write"
  }

  tfvars = {
    environment = "integration"
  }

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}

module "govuk-aws-users-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization           = var.organization
  workspace_name         = "govuk-aws-users-staging"
  workspace_desc         = "This manages the IAM roles and policies for the GOV.UK staging AWS account"
  workspace_tags         = ["user-management", "aws"]
  terraform_version      = var.terraform_version
  assessments_enabled    = true
  auto_apply             = true
  auto_apply_run_trigger = true
  execution_mode         = "remote"
  working_directory      = "/terraform/aws"
  trigger_patterns       = ["/terraform/aws/**/*", "/config/**/*"]

  project_name = "govuk-user-management"
  vcs_repo = {
    identifier     = "alphagov/govuk-user-reviewer"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"  = "read"
    "GOV.UK Senior Tech" = "write"
  }

  tfvars = {
    environment = "staging"
  }

  variable_set_ids = [
    local.aws_credentials["staging"]
  ]
}

module "govuk-aws-users-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization           = var.organization
  workspace_name         = "govuk-aws-users-production"
  workspace_desc         = "This manages the IAM roles and policies for the GOV.UK production AWS account"
  workspace_tags         = ["user-management", "aws"]
  terraform_version      = var.terraform_version
  assessments_enabled    = true
  auto_apply             = true
  auto_apply_run_trigger = true
  execution_mode         = "remote"
  working_directory      = "/terraform/aws"
  trigger_patterns       = ["/terraform/aws/**/*", "/config/**/*"]

  project_name = "govuk-user-management"
  vcs_repo = {
    identifier     = "alphagov/govuk-user-reviewer"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"  = "read"
    "GOV.UK Senior Tech" = "write"
  }

  tfvars = {
    environment = "production"
  }

  variable_set_ids = [
    local.aws_credentials["production"]
  ]
}