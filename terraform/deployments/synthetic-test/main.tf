terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["synthetic-test-assumer", "aws"]
    }
  }

  required_version = "~> 1.10"
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.68.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.13.1"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      product              = "govuk"
      system               = "govuk-synthetic-test"
      environment          = var.govuk_environment
      owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      cluster              = "govuk"
      repository           = "govuk-infrastructure"
      terraform-deployment = basename(abspath(path.root))
    }
  }
}
