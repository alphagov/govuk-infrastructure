locals {
  gcp_project_id = "ga4-aggregate-analytics"
}

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

provider "google" {
  project = local.gcp_project_id
}

resource "google_project" "project" {
  name            = local.gcp_project_id
  project_id      = local.gcp_project_id
  folder_id       = "278098142879"
  billing_account = "015C7A-FAF970-B0D375"
}

module "data_access_monitoring" {
  source                     = "./modules/data-access-monitoring"
  project_id                 = google_project.project.project_id
  notification_email_address = data.google_secret_manager_secret_version.slack_alert_channel_email_address.secret_data
}
