moved {
  from = module.ai-accelerator-integration
  to   = module.ai-accelerator-opensearch-integration
}

module "ai-accelerator-opensearch-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "ai-accelerator-opensearch-integration"
  workspace_desc    = "This module manages the resources needed for the ai-accelerator OpenSearch cluster"
  workspace_tags    = ["integration", "ai-accelerator-opensearch", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/ai-accelerator-opensearch/"
  trigger_patterns = [
    "/terraform/deployments/ai-accelerator-opensearch/**/*",
    "/terraform/shared-modules/opensearch-blue-green-deployment/**/*",
    "/terraform/shared-modules/s3/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/variables-common.tf",
    "/terraform/variables/integration/ai-accelerator-opensearch.tfvars"
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
    "integration/ai-accelerator-opensearch.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}
