terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["aws", "mobile-backend"]
    }
  }

  required_version = "~> 1.8"
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
      System               = "GOV.UK App"
      Environment          = var.govuk_environment
      Owner                = "govuk-app-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}

data "aws_caller_identity" "current" {}
