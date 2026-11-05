resource "tfe_project" "tools" {
  organization = var.organization
  name         = "tools"
}


module "tools_networking" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "tools_networking"
  workspace_desc    = "This module manages foundational cloud resources that are required for the tools account"
  workspace_tags    = ["networking", "tools"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/tools/networking/"
  trigger_patterns = [
    "/terraform/deployments/tools/networking/**/*"
  ]
  global_remote_state = true

  project_name = tfe_project.tools.name
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "tools-concourse"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_ids = [
    local.aws_credentials["tools"],
  ]
}

module "tools_cluster_infrastructure" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "tools-cluster-infrastructure"
  workspace_desc    = "This module manages foundational cloud resources that are required for the tools eks cluster"
  workspace_tags    = ["cluster-infrastructure", "tools"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/tools/cluster-infrastructure/"
  trigger_patterns = [
    "/terraform/deployments/tools/cluster-infrastructure/**/*"
  ]
  global_remote_state = true

  project_name = tfe_project.tools.name
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "tools-concourse"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_ids = [
    local.aws_credentials["tools"],
  ]
}

module "tools_cluster_access" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "tools-cluster-access"
  workspace_desc    = "This module manages access for the tools eks cluster"
  workspace_tags    = ["cluster-access", "tools"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/tools/cluster-access/"
  trigger_patterns = [
    "/terraform/deployments/tools/cluster-access/**/*"
  ]
  global_remote_state = true

  project_name = tfe_project.tools.name
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "tools-concourse"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_ids = [
    local.aws_credentials["tools"],
  ]
}


module "tools_cluster_services" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "tools-cluster-services"
  workspace_desc    = "This module manages foundational cloud resources that are required for the tools eks cluster"
  workspace_tags    = ["cluster-services", "tools"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/tools/cluster-services/"
  trigger_patterns = [
    "/terraform/deployments/tools/cluster-services/**/*"
  ]
  global_remote_state = true

  project_name = tfe_project.tools.name
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "tools-concourse"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_ids = [
    local.aws_credentials["tools"],
  ]
}

