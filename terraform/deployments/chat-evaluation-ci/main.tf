terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["chat-evaluation-ci", "test", "aws"]
    }
  }

  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      product              = "govuk"
      system               = "govuk-chat-evaluation"
      environment          = var.govuk_environment
      owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform-deployment = basename(abspath(path.root))
      Service              = "govuk-chat-evaluation-ci"
    }
  }
}
