module "gcp-ga4-analytics" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "gcp-ga4-analytics"
  workspace_desc      = "GCP project management for the GA4 production project"
  workspace_tags      = ["production", "ga4-analytics", "gcp"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/ga4-analytics/"
  trigger_patterns    = ["/terraform/deployments/ga4-analytics/**/*"]
  global_remote_state = true

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production"            = "write"
    "Google Cloud Data Production" = "write"
    "GOV.UK Non-Production (r/o)"  = "read"
  }

  variable_set_ids = [
    local.gcp_credentials["production"],
  ]
}
