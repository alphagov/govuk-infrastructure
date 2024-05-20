terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["tfc", "aws", "configuration"]
    }
  }

  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.55.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.26"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Product              = "GOV.UK"
      System               = "Terraform Cloud"
      Environment          = var.govuk_environment
      Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}

provider "google" {
  # Staging has a non-standard project ID
  project = local.google_project
  default_labels = {
    Product              = "GOV.UK"
    System               = "Terraform Cloud"
    Environment          = var.govuk_environment
    Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
    repository           = "govuk-infrastructure"
    terraform_deployment = basename(abspath(path.root))
  }
}

provider "tfe" {
  hostname     = var.tfc_hostname
  organization = var.tfc_organization_name
}
