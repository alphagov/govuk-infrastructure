terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["ga4-analytics", "gcp", "production"]
    }
  }
  required_version = "~> 1.10"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.31.0"
    }
  }
}

provider "google" {
  project = "ga4-analytics-352613"
}

resource "google_project" "project" {
  name            = "GA4 Analytics"
  project_id      = "ga4-analytics-352613"
  folder_id       = "278098142879"
  billing_account = "015C7A-FAF970-B0D375"
}
