terraform {
  cloud {
    organization = "govuk"
    workspaces {
      project = "govuk-data-engineering"
      name    = "gcp-gds-bq-processing"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }

  required_version = "~> 1.14"
}

provider "google" {
  project = "gds-bq-processing"
}

resource "google_project" "project" {
  name            = "gds-bq-processing"
  project_id      = "gds-bq-processing"
  folder_id       = "278098142879"
  billing_account = "015C7A-FAF970-B0D375"
}
