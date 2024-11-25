terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["cdn-analytics", "gcp"]
    }
  }
  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  default_labels = {
    product              = "gov-uk"
    system               = "terraform-cloud"
    environment          = var.govuk_environment
    owner                = "govuk-platform-engineering"
    repository           = "govuk-infrastructure"
    terraform_deployment = lower(basename(abspath(path.root)))
  }
}

resource "google_project_service" "services" {
  for_each = toset(
    [
      "bigquery.googleapis.com",
      "iam.googleapis.com"
    ]
  )

  service = each.key
}

data "google_project" "project" {}
