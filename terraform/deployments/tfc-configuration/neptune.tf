module "neptune-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "neptune-integration"
  workspace_desc      = "This module manages AWS resources for creating Neptune graph databases."
  workspace_tags      = ["integration", "neptune", "eks", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/neptune/"
  trigger_patterns    = ["/terraform/deployments/neptune/**/*"]
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

  envvars = {
    TF_CLI_ARGS_plan  = "-parallelism=30"
    TF_CLI_ARGS_apply = "-parallelism=30"
  }

  variable_set_ids = [
    local.aws_credentials["integration"],
    module.variable-set-integration.id,
    module.variable-set-neptune-integration.id
  ]
}

