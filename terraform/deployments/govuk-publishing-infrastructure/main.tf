terraform {
  backend "s3" {}

  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

locals {
  vpc_id               = data.terraform_remote_state.infra_networking.outputs.vpc_id
  internal_dns_zone_id = data.terraform_remote_state.infra_root_dns_zones.outputs.internal_root_zone_id
  redis_subnets        = data.terraform_remote_state.infra_networking.outputs.private_subnet_elasticache_ids

  default_tags = {
    project              = "replatforming"
    repository           = "govuk-infrastructure"
    terraform_deployment = basename(abspath(path.root))
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags { tags = local.default_tags }
}
