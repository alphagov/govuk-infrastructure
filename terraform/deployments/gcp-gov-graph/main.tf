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
      version = "~> 0.70.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }

  required_version = "~> 1.10"
}

module "environment_dev" {
  source = "./modules/gov-graph"

  name                         = "dev"
  google_cloud_billing_account = var.google_cloud_billing_account
  google_cloud_folder          = var.google_cloud_folder
  tfc_project_name             = var.tfe_project_name
  environment_workspace_name   = "govuk-knowledge-graph-dev"
  access_group_name            = "govuk-gcp-access-dev"
}

module "environment_staging" {
  source = "./modules/gov-graph"

  name = "staging"

  google_cloud_billing_account = var.google_cloud_billing_account
  google_cloud_folder          = var.google_cloud_folder
  tfc_project_name             = var.tfe_project_name
  environment_workspace_name   = "govuk-knowledge-graph-staging"
  access_group_name            = "govuk-gcp-access"
}

module "environment_production" {
  source = "./modules/gov-graph"

  name = "production"

  google_cloud_billing_account = var.google_cloud_billing_account
  google_cloud_folder          = var.google_cloud_folder
  tfc_project_name             = var.tfe_project_name
  environment_workspace_name   = "govuk-knowledge-graph-production"
  access_group_name            = "govuk-gcp-access"
}
