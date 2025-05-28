terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["release-assumer", "aws"]
    }
  }

  required_version = "~> 1.10"
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.66.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "< 5.98.1"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Product              = "GOV.UK"
      System               = "EKS release assumer"
      Environment          = var.govuk_environment
      Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      cluster              = "govuk"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}
