terraform {
  cloud {
    organization = "govuk"
    workspaces {
      project = "govuk-search-api-v2"
      name    = "search-api-v2-meta"
    }
  }

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.78.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }

  required_version = "~> 1.15"
}

module "environment_integration" {
  source = "./modules/search-api-v2"

  name                         = "integration"
  google_cloud_billing_account = var.google_cloud_billing_account
  google_cloud_folder          = var.google_cloud_folder
  tfc_project_name             = var.tfe_project_name
  environment_workspace_name   = "search-api-v2-integration"
  access_group_name            = "govuk-gcp-access-integration"
}

module "environment_staging" {
  source = "./modules/search-api-v2"

  name = "staging"

  google_cloud_billing_account = var.google_cloud_billing_account
  google_cloud_folder          = var.google_cloud_folder
  tfc_project_name             = var.tfe_project_name
  environment_workspace_name   = "search-api-v2-staging"
  access_group_name            = "govuk-gcp-access"
}

module "environment_production" {
  source = "./modules/search-api-v2"

  name = "production"

  google_cloud_billing_account = var.google_cloud_billing_account
  google_cloud_folder          = var.google_cloud_folder
  tfc_project_name             = var.tfe_project_name
  environment_workspace_name   = "search-api-v2-production"
  access_group_name            = "govuk-gcp-access"
}

removed {
  from = google_dataform_repository.search_v2_api
  lifecycle {
    destroy = false
  }
}
