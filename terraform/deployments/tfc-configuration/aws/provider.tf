terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["tfc", "aws", "configuration"]
    }
  }

  required_version = "~> 1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5"
    }

    tfe = {
      version = "~> 0.47.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "tfe" {
  hostname     = var.tfc_hostname
  organization = var.tfc_organization_name
}

