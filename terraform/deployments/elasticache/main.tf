terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["elasticache", "aws"]
    }
  }
  required_version = "~> 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.71"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      product              = "govuk"
      system               = "govuk-platform-engineering"
      service              = "elasticache"
      environment          = var.govuk_environment
      owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform-deployment = basename(abspath(path.root))
    }
  }
}
