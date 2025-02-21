module "elasticache-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization        = var.organization
  workspace_name      = "elasticache-integration"
  workspace_desc      = "Serverless ElastiCache instances"
  workspace_tags      = ["integration", "elasticache", "aws"]
  terraform_version   = var.terraform_version
  execution_mode      = "remote"
  working_directory   = "/terraform/deployments/elasticache/"
  trigger_patterns    = ["/terraform/deployments/elasticache/**/*"]
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
    local.aws_credentials["integration"],
    module.variable-set-common.id,
    module.variable-set-integration.id,
    module.variable-set-elasticache-integration.id
  ]
}
