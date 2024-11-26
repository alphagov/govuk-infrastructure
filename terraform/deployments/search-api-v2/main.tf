terraform {
  cloud {
    organization = "govuk"
    workspaces {
      project = "govuk-search-api-v2"

      # All workspaces for this module have this tag set up by `meta` module
      tags = ["search-api-v2-environment"]
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.41.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.27.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.19.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.2"
    }
  }

  required_version = "~> 1.7"
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "aws" {
  region = var.aws_region
}

# Used to extract access token from the provider so we can call the REST API
data "google_client_config" "default" {}

# Using REST API provider as a "temporary" workaround, as there are no native Terraform resources
# for Discovery Engine in the Google provider yet
provider "restapi" {
  uri = "https://discoveryengine.googleapis.com/${var.discovery_engine_api_version}/projects/${var.gcp_project_id}/locations/${var.discovery_engine_location}/collections/default_collection"

  # Writes in GCP APIs return an "operation" reference rather than the object being written
  write_returns_object = false

  # Discovery Engine API uses POST for create, PATCH for update
  create_method = "POST"
  update_method = "PATCH"

  headers = {
    # Piggyback on the the Terraform provider's generated temporary credentials to authenticate
    # to the API with
    "Authorization"       = "Bearer ${data.google_client_config.default.access_token}"
    "X-Goog-User-Project" = var.gcp_project_id
  }
}
