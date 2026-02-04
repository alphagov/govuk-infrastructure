terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["cluster-access", "aws"]
    }
  }

  required_version = "~> 1.14"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.73.0"
    }
    # The AWS provider is only used here for remote state in remote.tf. Please
    # do not add AWS resources to this module.
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.30.1"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      product              = "govuk"
      system               = "govuk-platform-engineering"
      service              = "eks-cluster-access"
      environment          = var.govuk_environment
      owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform-deployment = basename(abspath(path.root))
    }
  }
}

data "aws_iam_roles" "fulladmin" {
  name_regex = "\\..*-fulladmin$"
}

data "aws_iam_roles" "platformengineer" {
  name_regex = "\\..*platformengineer$"
}

data "aws_iam_roles" "developer" {
  name_regex = "\\..*developer$"
}

data "aws_iam_roles" "licensinguser" {
  name_regex = "\\..*licensinguser$"
}

data "aws_iam_roles" "ithctester" {
  name_regex = "\\..*ithctester$"
}

data "aws_iam_roles" "readonly" {
  name_regex = "\\..*readonly$"
}

data "aws_iam_roles" "dguengineer" {
  name_regex = "\\..*dguengineer$"
}

data "aws_eks_cluster_auth" "cluster_token" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_endpoint
  cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster_token.token
}

locals {
  cluster_name = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id
}
