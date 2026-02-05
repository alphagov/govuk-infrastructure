terraform {
  cloud {
    organization = "govuk"
    workspaces {
      project = "govuk-data-engineering"
      name    = "gcp-ga4-aggregate-analytics"
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

resource "google_project" "project" {
  name            = "ga4-aggregate-analytics"
  project_id      = "ga4-aggregate-analytics"
  folder_id       = "278098142879"
  billing_account = "015C7A-FAF970-B0D375"
}
