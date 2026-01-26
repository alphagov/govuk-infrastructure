terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["datagovuk-infrastructure", "eks", "aws"]
    }
  }

  required_version = "~> 1.12"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    fastly = {
      source  = "fastly/fastly"
      version = "~> 8.0"
    }
  }
}

locals {
  cluster_id    = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id
  services_ns   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_services_namespace
  oidc_provider = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      product              = "govuk"
      system               = "govuk-dgu"
      environment          = var.govuk_environment
      owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform-deployment = basename(abspath(path.root))
    }
  }
}

data "aws_eks_cluster_auth" "cluster_token" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_endpoint
  cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster_token.token
}

provider "helm" {
  # TODO: If/when TF makes provider configs a first-class language object,
  # reuse the identical config from above.
  kubernetes = {
    host                   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_endpoint
    cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster_token.token
  }
}

provider "fastly" {
  api_key = "test" # pragma: allowlist secret
}

data "fastly_ip_ranges" "fastly" {}
