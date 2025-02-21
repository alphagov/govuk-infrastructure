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
      version = "~> 0.64.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  required_version = "~> 1.10"
}

module "environment_integration" {
  source = "./modules/search-api-v2"

  name                         = "integration"
  google_cloud_billing_account = var.google_cloud_billing_account
  google_cloud_folder          = var.google_cloud_folder
  tfc_project_name             = var.tfe_project_name
  environment_workspace_name   = "search-api-v2-integration"
}

module "environment_staging" {
  source = "./modules/search-api-v2"

  name                      = "staging"
  upstream_environment_name = "integration"

  google_cloud_billing_account = var.google_cloud_billing_account
  google_cloud_folder          = var.google_cloud_folder
  tfc_project_name             = var.tfe_project_name
  environment_workspace_name   = "search-api-v2-staging"
}

module "environment_production" {
  source = "./modules/search-api-v2"

  name                      = "production"
  upstream_environment_name = "staging"

  google_cloud_billing_account = var.google_cloud_billing_account
  google_cloud_folder          = var.google_cloud_folder
  tfc_project_name             = var.tfe_project_name
  environment_workspace_name   = "search-api-v2-production"


  # NOTE: There are limits on the Google side on how high we are permitted to set these quotas. If
  # you attempt to increase these beyond the ceiling, a `COMMON_QUOTA_CONSUMER_OVERRIDE_TOO_HIGH`
  # error will be raised (including some metadata that should tell you what the current ceiling is)
  # and you will need to manually request a quota increase from Google through the console first
  # (see the environment module for the exact quota names you need to request increases for).
  discovery_engine_quota_search_requests_per_minute = 5000
  discovery_engine_quota_documents                  = 2000000
}
