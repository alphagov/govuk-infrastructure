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