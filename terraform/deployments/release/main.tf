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
      version = "~> 0.71.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.21.1"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      product              = "govuk"
      system               = "govuk-release"
      environment          = var.govuk_environment
      owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      cluster              = "govuk"
      repository           = "govuk-infrastructure"
      terraform-deployment = basename(abspath(path.root))
    }
  }
}
