resource "tfe_workspace" "github_production" {
  name              = "github-production"
  description       = "The github module is responsible for the AWS resources which constitute the EKS cluster."
  project_id        = tfe_project.govuk_infrastructure.id
  tag_names         = ["production", "github"]
  terraform_version = "1.4.5"
  working_directory = "/terraform/deployments/github/"
  trigger_patterns  = ["/terraform/deployments/github/**/*"]
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
  }
}

resource "tfe_workspace_variable_set" "github_common_production" {
  variable_set_id = tfe_variable_set.common_production.id
  workspace_id    = tfe_workspace.github_production.id
}
