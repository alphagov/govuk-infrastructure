terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["csp-reporter", "eks", "aws"]
    }
  }

  required_version = "~> 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      product              = "govuk"
      system               = "govuk-csp-reporter"
      environment          = var.govuk_environment
      owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      cluster              = "govuk"
      repository           = "govuk-infrastructure"
      terraform-deployment = basename(abspath(path.root))
    }
  }
}

data "tfe_outputs" "root_dns" {
  organization = "govuk"
  workspace    = "root-dns-${var.govuk_environment}"
}

data "aws_caller_identity" "current" {}
