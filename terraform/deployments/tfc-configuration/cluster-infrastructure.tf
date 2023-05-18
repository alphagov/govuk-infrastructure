resource "tfe_workspace" "cluster_infrastructure_integration" {
  name                      = "cluster-infrastructure-integration"
  description               = "The cluster-infrastructure module is responsible for the AWS resources which constitute the EKS cluster."
  project_id                = tfe_project.govuk_infrastructure.id
  tag_names                 = ["integration", "eks"]
  terraform_version         = "1.4.5"
  working_directory         = "/terraform/deployments/cluster-infrastructure/"
  trigger_patterns          = ["/terraform/deployments/cluster-infrastructure/**/*"]
  remote_state_consumer_ids = toset([tfe_workspace.cluster_services_integration.id])
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
  }
}

resource "tfe_workspace_variable_set" "cluster_infrastructure_common_integration" {
  variable_set_id = tfe_variable_set.common_integration.id
  workspace_id    = tfe_workspace.cluster_infrastructure_integration.id
}

data "tfe_outputs" "cluster_infrastructure_integration" {
  organization = "govuk"
  workspace = tfe_workspace.cluster_infrastructure_integration.name
}

resource "tfe_workspace" "cluster_infrastructure_staging" {
  name                      = "cluster-infrastructure-staging"
  description               = "The cluster-infrastructure module is responsible for the AWS resources which constitute the EKS cluster."
  project_id                = tfe_project.govuk_infrastructure.id
  tag_names                 = ["staging", "eks"]
  terraform_version         = "1.4.5"
  working_directory         = "/terraform/deployments/cluster-infrastructure/"
  trigger_patterns          = ["/terraform/deployments/cluster-infrastructure/**/*"]
  remote_state_consumer_ids = toset([data.tfe_workspace.cluster_services_staging.id])
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
  }
}

resource "tfe_workspace_variable_set" "cluster_infrastructure_common_staging" {
  variable_set_id = tfe_variable_set.common_staging.id
  workspace_id    = tfe_workspace.cluster_infrastructure_staging.id
}

resource "tfe_workspace" "cluster_infrastructure_production" {
  name                      = "cluster-infrastructure-production"
  description               = "The cluster-infrastructure module is responsible for the AWS resources which constitute the EKS cluster."
  project_id                = tfe_project.govuk_infrastructure.id
  tag_names                 = ["production", "eks"]
  terraform_version         = "1.4.5"
  working_directory         = "/terraform/deployments/cluster-infrastructure/"
  trigger_patterns          = ["/terraform/deployments/cluster-infrastructure/**/*"]
  remote_state_consumer_ids = toset([data.tfe_workspace.cluster_services_production.id])
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
  }
}

resource "tfe_workspace_variable_set" "cluster_infrastructure_common_production" {
  variable_set_id = tfe_variable_set.common_production.id
  workspace_id    = tfe_workspace.cluster_infrastructure_production.id
}
