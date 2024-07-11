terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["vpc", "eks", "aws"]
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

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Product              = "GOV.UK"
      System               = "VPC"
      Environment          = var.govuk_environment
      Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}

provider "google" {
  default_labels = {
    product              = "GOV.UK"
    system               = "Terraform Cloud"
    environment          = var.govuk_environment
    owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
    repository           = "govuk-infrastructure"
    terraform_deployment = basename(abspath(path.root))
  }
}
