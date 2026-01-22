module "govuk-fastly-secrets" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "govuk-fastly-secrets"
  workspace_desc      = "This workspace is used to create other Fastly workspaces in Terraform Cloud"
  workspace_tags      = ["fastly"]
  assessments_enabled = true
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform"

  project_name = "govuk-fastly"
  vcs_repo = {
    identifier     = "alphagov/govuk-fastly-secrets"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  variable_set_ids = [
    local.aws_credentials["production"]
  ]
}

import {
  to = module.govuk-fastly-secrets.tfe_workspace.ws
  id = "ws-AhhvhyjXYmiw3f2H"
}

import {
  to = module.govuk-fastly-secrets.tfe_workspace_settings.ws
  id = "ws-AhhvhyjXYmiw3f2H"
}

resource "tfe_project" "govuk-fastly" {
  name = "govuk-fastly"
}

import {
  to = tfe_project.govuk-fastly
  id = "prj-W6heeg89HJyX7w9p"
}

data "tfe_team" "production" {
  name         = "GOV.UK Production"
  organization = var.organization
}

resource "tfe_team_project_access" "production" {
  access     = "admin"
  team_id    = data.tfe_team.production.id
  project_id = tfe_project.govuk-fastly.id
}

import {
  to = tfe_team_project_access.production
  id = "tprj-cG8tTUvBMmrnkRhs"
}