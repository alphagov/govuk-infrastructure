resource "tfe_workspace" "datagovuk_infrastructure_integration" {
  name              = "datagovuk-infrastructure-integration"
  description       = "The datagovuk-infrastructure module is responsible for the AWS resources which constitute the EKS cluster."
  project_id        = tfe_project.govuk_infrastructure.id
  tag_names         = ["integration", "app"]
  terraform_version = "1.4.5"
  working_directory = "/terraform/deployments/datagovuk-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/datagovuk-infrastructure/**/*"]
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
  }
}

resource "tfe_workspace_variable_set" "datagovuk_infrastructure_common_integration" {
  variable_set_id = tfe_variable_set.common_integration.id
  workspace_id    = tfe_workspace.datagovuk_infrastructure_integration.id
}

resource "tfe_workspace" "datagovuk_infrastructure_staging" {
  name              = "datagovuk-infrastructure-staging"
  description       = "The datagovuk-infrastructure module is responsible for the AWS resources which constitute the EKS cluster."
  project_id        = tfe_project.govuk_infrastructure.id
  tag_names         = ["staging", "app"]
  terraform_version = "1.4.5"
  working_directory = "/terraform/deployments/datagovuk-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/datagovuk-infrastructure/**/*"]
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
  }
}

resource "tfe_workspace_variable_set" "datagovuk_infrastructure_common_staging" {
  variable_set_id = tfe_variable_set.common_staging.id
  workspace_id    = tfe_workspace.datagovuk_infrastructure_staging.id
}

resource "tfe_workspace" "datagovuk_infrastructure_production" {
  name              = "datagovuk-infrastructure-production"
  description       = "The datagovuk-infrastructure module is responsible for the AWS resources which constitute the EKS cluster."
  project_id        = tfe_project.govuk_infrastructure.id
  tag_names         = ["production", "app"]
  terraform_version = "1.4.5"
  working_directory = "/terraform/deployments/datagovuk-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/datagovuk-infrastructure/**/*"]
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
  }
}
resource "tfe_workspace_variable_set" "datagovuk_infrastructure_common_production" {
  variable_set_id = tfe_variable_set.common_production.id
  workspace_id    = tfe_workspace.datagovuk_infrastructure_production.id
}
