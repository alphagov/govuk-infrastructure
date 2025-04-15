module "workspace" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "${var.name}-${var.ephemeral_cluster_id}"
  workspace_desc      = "Resources for an ephemeral cluster"
  workspace_tags      = ["ephemeral", var.name, "aws", var.ephemeral_cluster_id]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/${var.name}/"
  trigger_patterns    = ["/terraform/deployments/${var.name}/**/*"]
  global_remote_state = true
  queue_all_runs      = false

  project_name = var.ephemeral_cluster_id
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Non-Production (r/o)" = "write"
    "GOV.UK Production"           = "write"
  }

  variable_set_ids   = [var.variable_set_id]
  variable_set_names = [
    "aws-credentials-test",
    "common",
    "common-ephemeral"
  ]
}

resource "tfe_workspace_run" "run" {
  workspace_id = module.workspace.workspace_id

  apply {
    manual_confirm = false
    wait_for_run   = true
    retry          = false
  }
}
