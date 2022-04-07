# The cluster-services module is responsible for Kubernetes objects within the
# EKS cluster.
#
# Any AWS resources relating to the cluster belong in
# ../cluster-infrastructure, not in this module.
#
# See https://github.com/alphagov/govuk-infrastructure/blob/main/docs/architecture/decisions/0003-split-terraform-state-into-separate-aws-cluster-and-kubernetes-resource-phases.md

terraform {
  backend "s3" {}

  required_version = "~> 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    # The AWS provider is only used here for remote state in remote.tf. Please
    # do not add AWS resources to this module.
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster_infrastructure.outputs.cluster_certificate_authority_data)
  exec {
    # TODO: use `client.authentication.k8s.io/v1beta1` once aws eks get-token
    # supports it (again). As of aws-cli 2.2.30 it still only supports
    # v1alpha1. https://github.com/aws/aws-cli/pull/6309
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.cluster_infrastructure.outputs.cluster_id]
  }
}

provider "helm" {
  # TODO: If/when TF makes provider configs a first-class language object,
  # reuse the identical config from above.
  kubernetes {
    host                   = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster_infrastructure.outputs.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.cluster_infrastructure.outputs.cluster_id]
    }
  }
}

locals {
  monitoring_ns          = data.terraform_remote_state.cluster_infrastructure.outputs.monitoring_namespace
  services_ns            = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_services_namespace
  external_dns_zone_name = data.terraform_remote_state.cluster_infrastructure.outputs.external_dns_zone_name
  alb_ingress_annotations = {
    "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
    "alb.ingress.kubernetes.io/target-type"  = "ip"
    "alb.ingress.kubernetes.io/listen-ports" = jsonencode([{ HTTP = 80 }, { HTTPS = 443 }])
    "alb.ingress.kubernetes.io/ssl-redirect" = "443"
    "alb.ingress.kubernetes.io/ssl-policy"   = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06" # No TLS 1.0 or 1.1.
  }
}
