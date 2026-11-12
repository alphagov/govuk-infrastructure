module "cilium-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization           = var.organization
  workspace_name         = "cilium-integration"
  workspace_desc         = "Manages the Cilium installation in an EKS cluster"
  workspace_tags         = ["integration", "cilium", "eks"]
  terraform_version      = var.terraform_version
  auto_apply             = false
  auto_apply_run_trigger = true
  execution_mode         = "remote"
  working_directory      = "/terraform/deployments/cilium/"
  trigger_patterns = [
    "/terraform/deployments/cilium/**/*",
    "/terraform/variables/integration/common.tfvars",
    "/terraform/variables/variables-common.tf"
  ]

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
    "integration/common.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["integration"]
  ]
}

module "cilium-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization           = var.organization
  workspace_name         = "cilium-staging"
  workspace_desc         = "Manages the Cilium installation in an EKS cluster"
  workspace_tags         = ["staging", "cilium", "eks"]
  terraform_version      = var.terraform_version
  auto_apply             = false
  auto_apply_run_trigger = true
  execution_mode         = "remote"
  working_directory      = "/terraform/deployments/cilium/"
  trigger_patterns = [
    "/terraform/deployments/cilium/**/*",
    "/terraform/variables/staging/common.tfvars",
    "/terraform/variables/variables-common.tf"
  ]

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
    "staging/common.tfvars"
  ]

  variable_set_ids = [
    local.aws_credentials["staging"]
  ]
}