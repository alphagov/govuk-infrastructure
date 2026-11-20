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
  working_directory = "/terraform/tools/networking/"
  trigger_patterns = [
    "/terraform/tools/networking/**/*",
    "/terraform/tools/variables/concourse/common.tfvars",
    "/terraform/tools/variables/concourse/networking.tfvars",
  ]
  global_remote_state = true

  project_name = tfe_project.tools.name
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "cluster-infrastructure-concourse"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  tfvars_files_prefix = "../"
  tfvars_files = [
    "variables/concourse/common.tfvars",
    "variables/concourse/networking.tfvars",
  ]

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
  working_directory = "/terraform/tools/cluster-infrastructure/"
  trigger_patterns = [
    "/terraform/tools/cluster-infrastructure/**/*",
    "/terraform/tools/variables/concourse/common.tfvars",
    "/terraform/tools/variables/concourse/cluster-infrastructure.tfvars",

  ]
  global_remote_state = true

  project_name = tfe_project.tools.name
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  tfvars_files_prefix = "../"
  tfvars_files = [
    "variables/concourse/common.tfvars",
    "variables/concourse/cluster-infrastructure.tfvars",
  ]

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
  working_directory = "/terraform/tools/cluster-services/"
  trigger_patterns = [
    "/terraform/tools/cluster-services/**/*"
  ]
  global_remote_state = true

  project_name = tfe_project.tools.name
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_ids = [
    local.aws_credentials["tools"],
  ]

  tfvars_files_prefix = "../"
  tfvars_files = [
    "variables/concourse/common.tfvars",
    "variables/concourse/cluster-services.tfvars",
  ]

}

module "concourse_concourse" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "concourse-concourse"
  workspace_desc    = "This module manages concourse resources inside the concourse eks cluster"
  workspace_tags    = ["concourse", "tools"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/tools/concourse/"
  trigger_patterns = [
    "/terraform/tools/concourse/**/*"
  ]
  global_remote_state = true

  project_name = tfe_project.tools.name
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_ids = [
    local.aws_credentials["tools"],
  ]

  tfvars_files_prefix = "../"
  tfvars_files = [
    "variables/concourse/common.tfvars",
    "variables/concourse/concourse.tfvars",
  ]
}
