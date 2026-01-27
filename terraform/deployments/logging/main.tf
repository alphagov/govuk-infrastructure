terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["logging", "aws"]
    }
  }
  required_version = "~> 1.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      product              = "govuk"
      system               = "govuk-platform-engineering"
      service              = "logging"
      environment          = var.govuk_environment
      owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      terraform-deployment = basename(abspath(path.root))
    }
  }
}

provider "google" {
  default_labels = {
    product              = "govuk"
    system               = "govuk-platform-engineering"
    service              = "logging"
    environment          = var.govuk_environment
    owner                = "govuk-platform-engineering"
    repository           = "govuk-infrastructure"
    terraform-deployment = lower(basename(abspath(path.root)))
  }
}
