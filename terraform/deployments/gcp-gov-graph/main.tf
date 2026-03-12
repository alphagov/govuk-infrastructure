terraform {
  cloud {
    organization = "govuk"
    workspaces {
      project = "govuk-data-engineering"
      name    = "gov-graph"
    }
  }

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.74.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }

  required_version = "~> 1.14"
}

locals {
  display_name = title(var.name)
}

resource "google_project" "environment_project" {
  name       = "Gov Graph ${local.display_name}"
  project_id = "gov-graph-${var.name}"

  folder_id       = var.google_cloud_folder
  billing_account = var.google_cloud_billing_account

  labels = {
    "programme"         = "govuk"
    "team"              = "govuk-data-engineering"
    "govuk_environment" = var.name
  }
}

resource "google_project_service" "api_service" {
  for_each = var.google_cloud_apis

  project                    = google_project.environment_project.project_id
  service                    = each.value
  disable_dependent_services = true
}