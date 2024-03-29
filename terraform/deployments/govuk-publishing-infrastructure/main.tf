terraform {
  #backend "s3" {}

  cloud {
    organization = "govuk"
    workspaces {
      tags = ["govuk-publishing-infrastructure", "eks", "aws"]
    }
  }

  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    fastly = {
      source  = "fastly/fastly"
      version = "~> 2.1"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.51.1"
    }
  }
}

locals {
  cluster_name         = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id
  vpc_id               = data.terraform_remote_state.infra_networking.outputs.vpc_id
  internal_dns_zone_id = data.terraform_remote_state.infra_root_dns_zones.outputs.internal_root_zone_id
  external_dns_zone_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.external_dns_zone_id
  elasticache_subnets  = data.terraform_remote_state.infra_networking.outputs.private_subnet_elasticache_ids

  default_tags = {
    Product              = "GOV.UK"
    Environment          = var.govuk_environment
    Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
    repository           = "govuk-infrastructure"
    terraform_deployment = basename(abspath(path.root))
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags { tags = local.default_tags }
}

provider "random" {}

# used by the fastly ip ranges provider.
# an API key is needed but 'fake' seems to work.
provider "fastly" {
  api_key = "fake"
}

# This will use credentials provided by `terraform login`
provider "tfe" {
}

data "aws_caller_identity" "current" {}
