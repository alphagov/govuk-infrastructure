#terraform {
#  cloud {
#    organization = "govuk"
#      project = "govuk-data-engineering"
#    workspaces {
#      tags    = ["gcp", "gov-graph"]
#    }
#  }

#  required_providers {
#    tfe = {
#      source  = "hashicorp/tfe"
#      version = "~> 0.74.0"
#    }
#    google = {
#      source  = "hashicorp/google"
#      version = "~> 7.0"
#    }
#  }

#  required_version = "~> 1.14"
#}

locals {
  display_name = title(var.name)
}

removed {
  from = google_project.environment_project
  lifecycle {
    destroy = false
  }
}