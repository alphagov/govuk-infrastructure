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
      version = "~> 7.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      product              = "govuk"
      system               = "govuk-app"
      environment          = var.govuk_environment
      owner                = "govuk-app-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform-deployment = basename(abspath(path.root))
    }
  }
}

provider "fastly" { api_key = "test" }
data "fastly_ip_ranges" "fastly" {}
