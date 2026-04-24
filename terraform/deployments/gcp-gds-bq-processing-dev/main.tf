terraform {
  cloud {
    organization = "govuk"
    workspaces {
      project = "govuk-data-engineering"
      name    = "gcp-gds-bq-processing-dev"
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
  project = "gds-bq-processing-dev"
}

module "project" {
  source = "../../shared-modules/gcp-project-init"

  project_id   = "gds-bq-processing-dev"
  project_name = "gds-bq-processing-dev"
}
