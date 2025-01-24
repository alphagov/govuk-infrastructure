terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["aws", "mobile-backend"]
    }
  }

  required_version = "~> 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    fastly = {
      source  = "fastly/fastly"
      version = "~> 5.13"
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

provider "fastly" { api_key = "test" }
data "fastly_ip_ranges" "fastly" {}
