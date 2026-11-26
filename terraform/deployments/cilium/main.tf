terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["cilium", "eks", "aws"]
    }
  }
  required_version = "~> 1.17"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "3.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.3.0"
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

provider "kubectl" {
  host                   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_endpoint
  cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.govuk.token
  load_config_file       = false
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
  version    = "1.20.5"

  values = [yamlencode({
    cni = {
      exclusive    = false,
      chainingMode = "aws-cni"
    }
    enableIPv4Masquerade = false
    routingMode          = "native"
    hubble = {
      enabled = true
      metrics = {
        enableOpenMetrics = true
        enabled           = true
      }
      relay = {
        enabled  = true
        replicas = 2
      }
      prometheus = {
        enabled = true
      }
      ui = {
        enabled  = true
        replicas = 2
      }
      export = {
        static = {
          enabled        = true
          filePath       = "/var/run/cilium/hubble/events.log"
          fileMaxSizeMb  = 1000
          fileMaxBackups = 2
          fileCompress   = true
        }
      }
    }
    # this value is used to ensure Cilium does not make breaking changes
    # to our config. It should be kept as-is unless a pre-flight check
    # fails and we have to perform configuration changes for an upgrade
    # to succeed.
    upgradeCompatibility = "1.20"
  })]
}
