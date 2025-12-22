module "chat-evaluation-ci-test" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "chat-evaluation-ci-test"
  workspace_desc      = "This module manages resources needed to operate the CI of GOV.UK Chat"
  workspace_tags      = ["test", "chat-evaluation-ci", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/chat-evaluation-ci/"
  trigger_patterns    = ["/terraform/deployments/chat-evaluation-ci/**/*"]
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

  variable_set_ids = [
    local.aws_credentials["test"],
  ]
}
