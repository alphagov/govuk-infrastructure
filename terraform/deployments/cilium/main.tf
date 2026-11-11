terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["cilium", "eks"]
    }
  }
  required_version = "~> 1.17"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Product              = "GOV.UK"
      System               = "Cilium"
      Environment          = var.govuk_environment
      Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}

data "aws_eks_cluster_auth" "govuk" {
  name = var.cluster_name
}

provider "kubernetes" {
  host = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_endpoint

  token                  = data.aws_eks_cluster_auth.govuk.token
  cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_certificate_authority_data)

}

provider "helm" {
  kubernetes = {
    host = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_endpoint

    token                  = data.aws_eks_cluster_auth.govuk.token
    cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_certificate_authority_data)
  }
}

resource "kubernetes_namespace_v1" "cilium" {
  metadata {
    name = "cilium"
  }
}

resource "helm_release" "cilium" {
  name      = "cilium"
  namespace = kubernetes_namespace_v1.cilium.metadata[0].name

  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.20.3"

  values = [yamlencode({
    cni = {
      exclusive    = false,
      chainingMode = "aws-cni"
    }
    enableIPv4Masquerade = false
    routingMode          = "native"
    hubble = {
      enabled = true
      relay = {
        enabled = true
      }
      ui = {
        enabled = true
      }
    }
  })]
}