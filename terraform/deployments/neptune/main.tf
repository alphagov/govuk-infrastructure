terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["neptune", "eks", "aws"]
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8"
    }
  }
}

provider "random" {}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Product              = "GOV.UK"
      System               = "EKS Neptune"
      Environment          = var.govuk_environment
      Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      cluster              = "govuk"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}

