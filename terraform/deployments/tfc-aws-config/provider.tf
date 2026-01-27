terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["tfc", "aws", "configuration"]
    }
  }

  required_version = "~> 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.73.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      product              = "govuk"
      system               = "govuk-platform-engineering"
      service              = "tfc-aws-config"
      environment          = var.govuk_environment
      owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform-deployment = basename(abspath(path.root))
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
