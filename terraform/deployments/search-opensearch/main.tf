terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["search-opensearch", "aws"]
    }
  }
  required_version = "~> 1.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Product              = "GOV.UK"
      Environment          = var.govuk_environment
      Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      Service              = "govuk-search"
      project              = "GOV.UK - Search"
      repository           = "govuk-infrastructure"
      terraform_deployment = "search-opensearch"
    }
  }
}

data "tfe_outputs" "root_dns" {
  organization = "govuk"
  workspace    = "root-dns-${var.govuk_environment}"
}
