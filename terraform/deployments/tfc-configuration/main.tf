terraform {
  cloud {
    organization = "govuk"
    workspaces {
      name = "tfc-configuration"
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
  token        = var.tfe_token
}

data "tfe_github_app_installation" "github" {
  name = "alphagov"
}

resource "tfe_project" "govuk_infrastructure" {
  name = "govuk-infrastructure"
}

resource "tfe_project_variable_set" "govuk_infrastructure" {
  variable_set_id = tfe_variable_set.common.id
  project_id      = tfe_project.govuk_infrastructure.id
}
