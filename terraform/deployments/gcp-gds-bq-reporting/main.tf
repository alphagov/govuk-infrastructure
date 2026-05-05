terraform {
  cloud {
    organization = "govuk"
    workspaces {
      project = "govuk-data-engineering"
      name    = "gcp-gds-bq-reporting"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.30.0"
    }
  }

  required_version = "~> 1.14"
}

provider "google" {
  project = "gds-bq-reporting"
}
