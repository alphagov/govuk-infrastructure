module "opensearch-integration" {
  source  = "alexbasista/workspacer/tfe"
  version = "0.10.0"

  organization      = var.organization
  workspace_name    = "opensearch-integration"
  workspace_desc    = "This module manages AWS resources for creating OpenSearch cluster."
  workspace_tags    = ["integration", "cluster-services", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/opensearch/"
  trigger_patterns  = ["/terraform/deployments/opensearch/**/*"]

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Non-Production" = "write"
    "GOV.UK Production"     = "write"
  }

  variable_set_names = [
    "aws-credentials-integration",
    "common",
    "common-integration"
  ]

  tfvars = {
    hosted_zone_name         = "chat"
    engine_version           = "2.11"
    security_options_enabled = true
    volume_type              = "gp3"
    throughput               = 250
    ebs_enabled              = true
    ebs_volume_size          = 45
    service                  = "chat"
    instance_type            = "m6g.large.search"
    instance_count           = 3
    dedicated_master_enabled = true
    dedicated_master_count   = 3
    dedicated_master_type    = "m6g.large.search"
    zone_awareness_enabled   = true
  }
}
