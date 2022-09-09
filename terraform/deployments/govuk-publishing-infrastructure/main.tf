terraform {
  backend "s3" {}

  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster_infrastructure.outputs.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.cluster_infrastructure.outputs.cluster_id]
  }
}

locals {
  cluster_name         = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_id
  vpc_id               = data.terraform_remote_state.infra_networking.outputs.vpc_id
  internal_dns_zone_id = data.terraform_remote_state.infra_root_dns_zones.outputs.internal_root_zone_id
  external_dns_zone_id = data.terraform_remote_state.cluster_infrastructure.outputs.external_dns_zone_id
  elasticache_subnets  = data.terraform_remote_state.infra_networking.outputs.private_subnet_elasticache_ids

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

provider "random" {}
