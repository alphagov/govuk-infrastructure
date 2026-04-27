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

module "managed_project" {
  source = "../../shared-modules/gcp-project-init"

  project_id   = "gds-bq-processing-dev"
  project_name = "gds-bq-processing-dev"
  project_owners = [
    "group:gcp-gds-bq-processing-dev-owners@digital.cabinet-office.gov.uk",
  ]
  project_editors = [
    "group:gcp-gds-bq-processing-dev-editors@digital.cabinet-office.gov.uk",
    "serviceAccount:912027178151-compute@developer.gserviceaccount.com",
  ]
}
