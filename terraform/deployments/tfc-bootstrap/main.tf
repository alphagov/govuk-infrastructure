resource "tfe_workspace" "tfc_bootstrap" {
  name              = "tfc-bootstrap"
  description       = "The tfc-bootsrap module is responsible for initialising teraform cloud."
  working_directory = "/terraform/deployments/tfc-bootstrap/"
  trigger_patterns  = ["/terraform/deployments/tfc-bootstrap/**/*"]
  execution_mode    = "local"
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
  }
}

resource "tfe_project" "tfc_configuration" {
  name = "tfc-configuration"
}

resource "tfe_workspace" "tfc_configuration" {
  name              = "tfc-configuration"
  description       = "The tfc-configuration module is responsible for setting up the terraform cloud configuration."
  project_id        = tfe_project.tfc_configuration.id
  working_directory = "/terraform/deployments/tfc-configuration/"
  trigger_patterns  = ["/terraform/deployments/tfc-configuration/**/*"]
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
    branch                     = "main"
  }
}
