terraform {
  backend "s3" {}

  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
  cluster_name  = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_id
  cluster_id    = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_id
  oidc_provider = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_oidc_provider

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
