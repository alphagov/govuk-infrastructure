terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["govuk-publishing-infrastructure", "eks", "aws"]
    }
  }

  required_version = "~> 1.10"
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
      version = "~> 5.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.63.0"
    }
  }
}

locals {
  cluster_name         = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id
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

provider "aws" {
  region = "eu-west-2"
  alias  = "replica"
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

provider "google" {
  default_labels = {
    product              = "gov-uk"
    system               = "terraform-cloud"
    environment          = var.govuk_environment
    owner                = "govuk-platform-engineering"
    repository           = "govuk-infrastructure"
    terraform_deployment = lower(basename(abspath(path.root)))
  }
}

data "aws_caller_identity" "current" {}
