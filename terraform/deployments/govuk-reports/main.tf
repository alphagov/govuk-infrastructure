terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["aws", "govuk-reports"]
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.5"
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      product              = "govuk"
      system               = "reports"
      environment          = var.govuk_environment
      managed-by           = "terraform"
      repository           = "govuk-infrastructure"
      terraform-deployment = "govuk-reports"
    }
  }
}

