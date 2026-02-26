module "ai-accelerator-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "ai-accelerator"
  workspace_desc    = "This module manages the resources needed for the ai-accelerator"
  workspace_tags    = ["integration", "ai-accelerator", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/ai-accelerator/"
  trigger_patterns = [
    "/terraform/deployments/ai-accelerator/**/*",
    "/terraform/shared-modules/opensearch-blue-green-deployment/**/*",
  ]
  global_remote_state = true

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "add-opensearch-deployment" ## FIXME: Change to main
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Non-Production (r/o)" = "write"
    "GOV.UK Production"           = "write"
  }

  variable_set_ids = [
    local.aws_credentials["integration"],
    module.variable-set-integration.id,
    module.variable-set-ai-accelerator-integration.id
  ]
}
