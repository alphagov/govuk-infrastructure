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

import {
  to = module.govuk-aws-users-tools.tfe_workspace.ws
  id = "ws-GuAATs5Xj5GvGFnu"
}

import {
  to = module.govuk-aws-users-test.tfe_workspace.ws
  id = "ws-iWw7XYrWWHm865Dt"
}

import {
  to = module.govuk-aws-users-integration.tfe_workspace.ws
  id = "ws-8vBgfSTp3mstsavn"
}

import {
  to = module.govuk-aws-users-staging.tfe_workspace.ws
  id = "ws-snbwLE23ck44VQF1"
}

import {
  to = module.govuk-aws-users-production.tfe_workspace.ws
  id = "ws-tUoLhaRRcdagm2AR"
}

import {
  to = module.govuk-aws-users-tools.tfe_workspace_settings.ws
  id = "ws-GuAATs5Xj5GvGFnu"
}

import {
  to = module.govuk-aws-users-test.tfe_workspace_settings.ws
  id = "ws-iWw7XYrWWHm865Dt"
}

import {
  to = module.govuk-aws-users-integration.tfe_workspace_settings.ws
  id = "ws-8vBgfSTp3mstsavn"
}

import {
  to = module.govuk-aws-users-staging.tfe_workspace_settings.ws
  id = "ws-snbwLE23ck44VQF1"
}

import {
  to = module.govuk-aws-users-production.tfe_workspace_settings.ws
  id = "ws-tUoLhaRRcdagm2AR"
}

import {
  to = module.govuk-aws-users-tools.tfe_team_access.managed["GOV.UK Production"]
  id = "govuk/govuk-aws-users-tools/tws-DpkQcGNHrbEidHAg"
}

import {
  to = module.govuk-aws-users-tools.tfe_team_access.managed["GOV.UK Senior Tech"]
  id = "govuk/govuk-aws-users-tools/tws-uU8M8gCftLqvKqE9"
}

import {
  to = module.govuk-aws-users-test.tfe_team_access.managed["GOV.UK Production"]
  id = "govuk/govuk-aws-users-test/tws-GSWLv1S9ngNrsWDp"
}

import {
  to = module.govuk-aws-users-test.tfe_team_access.managed["GOV.UK Senior Tech"]
  id = "govuk/govuk-aws-users-test/tws-22XKZtSg7dqVLc9m"
}

import {
  to = module.govuk-aws-users-integration.tfe_team_access.managed["GOV.UK Production"]
  id = "govuk/govuk-aws-users-integration/tws-UNAZ9B1kTbGDDbMN"
}

import {
  to = module.govuk-aws-users-integration.tfe_team_access.managed["GOV.UK Senior Tech"]
  id = "govuk/govuk-aws-users-integration/tws-wcCk8eG8LL9kjsf4"
}

import {
  to = module.govuk-aws-users-staging.tfe_team_access.managed["GOV.UK Production"]
  id = "govuk/govuk-aws-users-staging/tws-wBQeriM42kq1ZbWq"
}

import {
  to = module.govuk-aws-users-staging.tfe_team_access.managed["GOV.UK Senior Tech"]
  id = "govuk/govuk-aws-users-staging/tws-S2KsUFpKaPJcsh1a"
}

import {
  to = module.govuk-aws-users-production.tfe_team_access.managed["GOV.UK Production"]
  id = "govuk/govuk-aws-users-production/tws-qxfKchGRQ2UX3ce8"
}

import {
  to = module.govuk-aws-users-production.tfe_team_access.managed["GOV.UK Senior Tech"]
  id = "govuk/govuk-aws-users-production/tws-EZhjxuxiQe8zDri5"
}

import {
  to = module.govuk-aws-users-tools.tfe_workspace_variable_set.vs_ids[0]
  id = "govuk/govuk-aws-users-tools/aws-credentials-tools"
}

import {
  to = module.govuk-aws-users-test.tfe_workspace_variable_set.vs_ids[0]
  id = "govuk/govuk-aws-users-test/aws-credentials-test"
}

import {
  to = module.govuk-aws-users-integration.tfe_workspace_variable_set.vs_ids[0]
  id = "govuk/govuk-aws-users-integration/aws-credentials-integration"
}

import {
  to = module.govuk-aws-users-staging.tfe_workspace_variable_set.vs_ids[0]
  id = "govuk/govuk-aws-users-staging/aws-credentials-staging"
}

import {
  to = module.govuk-aws-users-production.tfe_workspace_variable_set.vs_ids[0]
  id = "govuk/govuk-aws-users-production/aws-credentials-production"
}

import {
  to = module.govuk-aws-users-tools.tfe_variable.tfvars["environment"]
  id = "govuk/govuk-aws-users-tools/var-U8MB9nkR4WFnVPjc"
}

import {
  to = module.govuk-aws-users-test.tfe_variable.tfvars["environment"]
  id = "govuk/govuk-aws-users-test/var-kNnXSbyuYWB3hzNM"
}

import {
  to = module.govuk-aws-users-integration.tfe_variable.tfvars["environment"]
  id = "govuk/govuk-aws-users-integration/var-NxGHqD79PrXeabWt"
}

import {
  to = module.govuk-aws-users-staging.tfe_variable.tfvars["environment"]
  id = "govuk/govuk-aws-users-staging/var-i7kV5n4hQtxgXMj7"
}

import {
  to = module.govuk-aws-users-production.tfe_variable.tfvars["environment"]
  id = "govuk/govuk-aws-users-production/var-djcwCYhxoUk8GauF"
}