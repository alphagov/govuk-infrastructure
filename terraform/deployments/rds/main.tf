terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["rds", "eks", "aws"]
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "random" {}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Product              = "GOV.UK"
      System               = "EKS RDS"
      Environment          = var.govuk_environment
      Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      cluster              = "govuk"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}
