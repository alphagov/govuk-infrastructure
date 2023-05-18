resource "tfe_workspace" "govuk_publishing_infrastructure_integration" {
  name              = "govuk-publishing-infrastructure-integration"
  description       = "The govuk-publishing-infrastructure module is responsible for the AWS resources which constitute the EKS cluster."
  project_id        = tfe_project.govuk_infrastructure.id
  tag_names         = ["integration", "infra"]
  terraform_version = "1.4.5"
  working_directory = "/terraform/deployments/govuk-publishing-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/govuk-publishing-infrastructure/**/*"]
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
  }
}

resource "tfe_workspace_variable_set" "govuk_publishing_infrastructure_common_integration" {
  variable_set_id = tfe_variable_set.common_integration.id
  workspace_id    = tfe_workspace.govuk_publishing_infrastructure_integration.id
}

resource "tfe_workspace" "govuk_publishing_infrastructure_staging" {
  name              = "govuk-publishing-infrastructure-staging"
  description       = "The govuk-publishing-infrastructure module is responsible for the AWS resources which constitute the EKS cluster."
  project_id        = tfe_project.govuk_infrastructure.id
  tag_names         = ["staging", "infra"]
  terraform_version = "1.4.5"
  working_directory = "/terraform/deployments/govuk-publishing-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/govuk-publishing-infrastructure/**/*"]
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
  }
}

resource "tfe_workspace_variable_set" "govuk_publishing_infrastructure_common_staging" {
  variable_set_id = tfe_variable_set.common_staging.id
  workspace_id    = tfe_workspace.govuk_publishing_infrastructure_staging.id
}

resource "tfe_workspace" "govuk_publishing_infrastructure_production" {
  name              = "govuk-publishing-infrastructure-production"
  description       = "The govuk-publishing-infrastructure module is responsible for the AWS resources which constitute the EKS cluster."
  project_id        = tfe_project.govuk_infrastructure.id
  tag_names         = ["production", "infra"]
  terraform_version = "1.4.5"
  working_directory = "/terraform/deployments/govuk-publishing-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/govuk-publishing-infrastructure/**/*"]
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
  }
}

resource "tfe_workspace_variable_set" "govuk_publishing_infrastructure_common_production" {
  variable_set_id = tfe_variable_set.common_production.id
  workspace_id    = tfe_workspace.govuk_publishing_infrastructure_production.id
}
