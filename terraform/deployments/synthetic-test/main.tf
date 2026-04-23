terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["synthetic-test", "aws"]
    }
  }

  required_version = "~> 1.14"
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.76.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.37.1"
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
