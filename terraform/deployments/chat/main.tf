terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["opensearch", "eks", "aws"]
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

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.default_tags
  }
}

locals {
  default_tags = {
    product              = "govuk"
    system               = "govuk-chat"
    environment          = var.govuk_environment
    owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
    repository           = "govuk-infrastructure"
    terraform-deployment = basename(abspath(path.root))
  }

  internal_dns_zone_id = data.terraform_remote_state.infra_root_dns_zones.outputs.internal_root_zone_id
}
