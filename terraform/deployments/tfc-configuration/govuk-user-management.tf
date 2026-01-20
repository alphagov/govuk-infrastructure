module "govuk-user-management" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "govuk-user-management"
  workspace_desc      = "This module manages user access to Fastly, PagerDuty and GitHub Teams"
  workspace_tags      = ["govuk-user-management"]
  assessments_enabled = true
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "./terraform/saas"
  auto_apply          = true
  trigger_patterns    = ["/terraform/saas/**/*", "/config/*.yml"]

  project_name = "govuk-user-management"
  vcs_repo = {
    identifier     = "alphagov/govuk-user-reviewer"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  custom_team_access = {
    "GOV.UK Production" = {
      runs              = "plan"
      variables         = "write"
      state_versions    = "read"
      sentinel_mocks    = "none"
      workspace_locking = false
      run_tasks         = false
    }
  }

  team_access = {
    "GOV.UK Senior Tech" = "write"
  }
}

resource "tfe_project" "govuk-user-management" {
  name = "govuk-user-management"
}

import {
  to = module.govuk-user-management.tfe_workspace.ws
  id = "ws-MnwZqzrMxschrrkD"
}

import {
  to = tfe_project.govuk-user-management
  id = "prj-NbYmntuGrcpe47Ho"
}

import {
  to = module.govuk-user-management.tfe_workspace_settings.ws
  id = "ws-MnwZqzrMxschrrkD"
}

import {
  to = module.govuk-user-management.tfe_team_access.custom["GOV.UK Production"]
  id = "govuk/govuk-user-management/tws-zwt11uDQdvvUx9Ce"
}

import {
  to = module.govuk-user-management.tfe_team_access.managed["GOV.UK Senior Tech"]
  id = "govuk/govuk-user-management/tws-qp3Ha1n6J5P6pGg4"
}
