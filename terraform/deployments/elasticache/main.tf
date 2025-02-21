terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["elasticache", "aws"]
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
