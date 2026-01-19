module "dns" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "govuk-dns-tf"
  workspace_desc      = "This module manages DNS records for GOV.UK subdomains."
  workspace_tags      = ["dns"]
  assessments_enabled = true
  terraform_version   = var.terraform_version
  execution_mode      = "remote"

  project_name = "govuk-dns"
  vcs_repo = {
    identifier     = "alphagov/govuk-dns-tf"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_ids = [
    local.aws_credentials["production"],
    local.gcp_credentials["production"],
  ]
}

resource "tfe_project" "govuk-dns" {
  name = "govuk-dns"
}

import {
  to = tfe_project.govuk-dns
  id = "prj-Sg3AQSpU79EmgwN1"
}

import {
  to = module.dns.tfe_workspace.ws
  id = "ws-EywpWWa2sGdR3VNh"
}

import {
  to = module.dns.tfe_workspace_settings.ws
  id = "ws-EywpWWa2sGdR3VNh"
}

import {
  to = module.dns.tfe_team_access.managed["GOV.UK Production"]
  id = "govuk/govuk-dns-tf/tws-p9duBCTAQwHmGAQX"
}

import {
  to = module.dns.tfe_workspace_variable_set.vs_ids[0]
  id = "govuk/govuk-dns-tf/aws-credentials-production"
}

import {
  to = module.dns.tfe_workspace_variable_set.vs_ids[1]
  id = "govuk/govuk-dns-tf/gcp-credentials-production"
}
