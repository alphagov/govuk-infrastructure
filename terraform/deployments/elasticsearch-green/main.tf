terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["elasticsearch", "aws"]
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
      aws_environment      = var.govuk_environment
      project              = "GOV.UK - Search"
      terraform_deployment = "app-elasticsearch6-green"
      Project              = "green"
      aws_stackname        = "green"
      Name                 = "green-elasticsearch6"
    }
  }
}
