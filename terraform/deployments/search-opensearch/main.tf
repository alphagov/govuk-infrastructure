terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["search-opensearch", "aws"]
    }
  }
  required_version = "~> 1.16"
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
      aws_environment      = var.govuk_environment
      project              = "GOV.UK - Search"
      terraform_deployment = "search-opensearch"
    }
  }
}

data "tfe_outputs" "root_dns" {
  organization = "govuk"
  workspace    = "root-dns-${var.govuk_environment}"
}
