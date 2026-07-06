terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["service-linked-roles", "aws"]
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
      project              = "GOV.UK"
      terraform_deployment = "service-linked-roles"
    }
  }
}

resource "aws_iam_service_linked_role" "es_role" {
  aws_service_name = "es.amazonaws.com"

  lifecycle {
    prevent_destroy = true
  }
}
