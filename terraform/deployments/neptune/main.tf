terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["neptune", "eks", "aws"]
    }
  }

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
      Product              = "GOV.UK"
      System               = "EKS Neptune"
      Environment          = var.govuk_environment
      Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      cluster              = "govuk"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}

data "aws_eks_cluster_auth" "cluster_token" {
  name = var.govuk_environment
}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_endpoint
  cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster_token.token
}

