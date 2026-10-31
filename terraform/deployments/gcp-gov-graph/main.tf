terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["gcp", "gov-graph"]
    }
  }

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.83.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 8.0"
    }
  }

  required_version = "~> 1.14"
}

locals {
  display_name = title(var.name)
}