terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["opensearch", "govuk", "aws"]
    }
  }

  required_version = "~> 1.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.34"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      product              = "govuk"
      system               = "govuk-ai-accelerator"
      Service              = "govuk-ai-accelerator"
      environment          = var.govuk_environment
      owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform-deployment = basename(abspath(path.root))
      Service              = "govuk-ai-accelerator"
    }
  }
}

provider "random" {}
