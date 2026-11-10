resource "tfe_project" "tools" {
  organization = var.organization
  name         = "tools"
}


module "tools_networking" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "networking-concourse"
  workspace_desc    = "This module manages foundational cloud resources that are required for the tools account concourse cluster"
  workspace_tags    = ["networking", "tools", "concourse"]
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
  workspace_name    = "cluster-infrastructure-concourse"
  workspace_desc    = "This module manages foundational cloud resources that are required for the tools concourse eks cluster"
  workspace_tags    = ["cluster-infrastructure", "tools", "concourse"]
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
  workspace_name    = "cluster-access-concourse"
  workspace_desc    = "This module manages access for the tools concourse eks cluster"
  workspace_tags    = ["cluster-access", "tools", "concourse"]
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
  workspace_name    = "cluster-services-concourse"
  workspace_desc    = "This module manages foundational cloud resources that are required for the tools concourse eks cluster services"
  workspace_tags    = ["cluster-services", "tools", "concourse"]
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

module "tools_concourse" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "tools-concourse"
  workspace_desc    = "This module manages concourse resources inside the concourse eks cluster"
  workspace_tags    = ["concourse", "tools"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/tools/concourse/"
  trigger_patterns = [
    "/terraform/deployments/tools/concourse/**/*"
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
