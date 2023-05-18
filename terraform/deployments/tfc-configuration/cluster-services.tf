resource "tfe_workspace" "cluster_services_integration" {
  name              = "cluster-services-integration"
  description       = "The cluster-services module is responsible for the AWS resources which constitute the EKS cluster."
  project_id        = tfe_project.govuk_infrastructure.id
  tag_names         = ["integration", "eks"]
  terraform_version = "1.4.5"
  working_directory = "/terraform/deployments/cluster-services/"
  trigger_patterns  = ["/terraform/deployments/cluster-services/**/*"]
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
  }
}

resource "tfe_workspace_variable_set" "cluster_services_common_integration" {
  variable_set_id = tfe_variable_set.common_integration.id
  workspace_id    = tfe_workspace.cluster_services_integration.id
}

resource "tfe_workspace" "cluster_services_staging" {
  name              = "cluster-services-staging"
  description       = "The cluster-services module is responsible for the AWS resources which constitute the EKS cluster."
  project_id        = tfe_project.govuk_infrastructure.id
  tag_names         = ["staging", "eks"]
  terraform_version = "1.4.5"
  working_directory = "/terraform/deployments/cluster-services/"
  trigger_patterns  = ["/terraform/deployments/cluster-services/**/*"]
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
  }
}

data "tfe_workspace" "cluster_services_staging" {
  name = "cluster-services-staging"
}

resource "tfe_workspace_variable_set" "cluster_services_common_staging" {
  variable_set_id = tfe_variable_set.common_staging.id
  workspace_id    = tfe_workspace.cluster_services_staging.id
}

resource "tfe_workspace" "cluster_services_production" {
  name              = "cluster-services-production"
  description       = "The cluster-services module is responsible for the AWS resources which constitute the EKS cluster."
  project_id        = tfe_project.govuk_infrastructure.id
  tag_names         = ["production", "eks"]
  terraform_version = "1.4.5"
  working_directory = "/terraform/deployments/cluster-services/"
  trigger_patterns  = ["/terraform/deployments/cluster-services/**/*"]
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
  }
}
data "tfe_workspace" "cluster_services_production" {
  name = "cluster-services-production"
}

resource "tfe_workspace_variable_set" "cluster_services_common_production" {
  variable_set_id = tfe_variable_set.common_production.id
  workspace_id    = tfe_workspace.cluster_services_production.id
}
