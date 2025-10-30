# The cluster-services module is responsible for Kubernetes objects within the
# EKS cluster.
#
# Any AWS resources relating to the cluster belong in
# ../cluster-infrastructure, not in this module.
#
# See https://github.com/alphagov/govuk-infrastructure/blob/main/docs/architecture/decisions/0003-split-terraform-state-into-separate-aws-cluster-and-kubernetes-resource-phases.md

terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["cluster-services", "aws"]
    }
  }

  required_version = "~> 1.10"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.70.0"
    }
    # The AWS provider is only used here for remote state in remote.tf. Please
    # do not add AWS resources to this module.
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.18.1"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      product              = "govuk"
      system               = "govuk-platform-engineering"
      service              = "eks-cluster-services"
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

locals {
  monitoring_ns          = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.monitoring_namespace
  services_ns            = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_services_namespace
  external_dns_zone_name = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.external_dns_zone_name
  alb_ingress_annotations = {
    "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
    "alb.ingress.kubernetes.io/target-type"  = "ip"
    "alb.ingress.kubernetes.io/listen-ports" = jsonencode([{ HTTP = 80 }, { HTTPS = 443 }])
    "alb.ingress.kubernetes.io/ssl-redirect" = "443"
    "alb.ingress.kubernetes.io/ssl-policy"   = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  }
  dex_host                  = "dex.${local.external_dns_zone_name}"
  alertmanager_host         = "alertmanager.${local.external_dns_zone_name}"
  grafana_host              = "grafana.${local.external_dns_zone_name}"
  prometheus_host           = "prometheus.${local.external_dns_zone_name}"
  prometheus_internal_url   = "http://kube-prometheus-stack-prometheus:9090"
  alertmanager_internal_url = "http://kube-prometheus-stack-alertmanager:9093"
  is_ephemeral              = startswith(var.govuk_environment, "eph-")
  elb_name_suffix           = local.is_ephemeral ? "-${var.govuk_environment}" : ""
}
