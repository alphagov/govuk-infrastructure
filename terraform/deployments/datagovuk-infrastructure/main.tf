terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["datagovuk-infrastructure", "eks", "aws"]
    }
  }

  required_version = "~> 1.5"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    fastly = {
      source  = "fastly/fastly"
      version = "~> 5.7"
    }
  }
}

locals {
  cluster_id    = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id
  services_ns   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_services_namespace
  oidc_provider = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider

  default_tags = {
    Product              = "DATA.GOV.UK"
    System               = "DATA.GOV.UK"
    Environment          = var.govuk_environment
    Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
    project              = "replatforming"
    repository           = "govuk-infrastructure"
    terraform_deployment = basename(abspath(path.root))
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags { tags = local.default_tags }
}

data "aws_eks_cluster_auth" "cluster_token" {
  name = "govuk"
}

provider "kubernetes" {
  host                   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_endpoint
  cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster_token.token
}

provider "helm" {
  # TODO: If/when TF makes provider configs a first-class language object,
  # reuse the identical config from above.
  kubernetes {
    host                   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_endpoint
    cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster_token.token
  }
}

provider "fastly" { api_key = "test" }

data "fastly_ip_ranges" "fastly" {}
