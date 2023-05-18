terraform {
  cloud {
    organization = "govuk"
    workspaces {
      name = "tfc-bootstrap"
    }
  }
  required_providers {
    tfe = {
      version = "~> 0.44.0"
    }
  }
}
variable "tfe_token" {
  description = "(Required) A Terraform cloud API token."
  sensitive   = true
  type        = string
}

provider "tfe" {
  organization = "govuk"
  token = var.tfe_token
}

data "tfe_github_app_installation" "github" {
  name  = "alphagov"
}

resource "tfe_workspace" "tfc_bootstrap" {
  name              = "tfc-bootstrap"
  description       = "The tfc-bootsrap module is responsible for initialising teraform cloud."
  terraform_version = "1.4.5"
  working_directory = "/terraform/deployments/tfc-configuration/"
  trigger_patterns  = ["/terraform/deployments/tfc-configuration/**/*"]
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
  terraform_version = "1.4.5"
  working_directory = "/terraform/deployments/tfc-configuration/"
  trigger_patterns  = ["/terraform/deployments/tfc-configuration/**/*"]
  vcs_repo {
    identifier                 = "alphagov/govuk-infrastructure"
    github_app_installation_id = data.tfe_github_app_installation.github.id
    branch                     = "marc/tfc-config"
  }
}
