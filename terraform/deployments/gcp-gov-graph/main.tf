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
  name       = var.project_id
  project_id = var.project_id

  folder_id       = var.folder_id
  billing_account = var.billing_account
  deletion_policy = "DELETE"

  labels = {
    "programme"         = "govuk"
    "team"              = "govuk-data-engineering"
    "govuk_environment" = var.name
  }
}

resource "google_project_service" "api_service" {
  for_each = var.services

  project                    = google_project.environment_project.project_id
  service                    = each.value
  disable_dependent_services = false
  disable_on_destroy         = false
}