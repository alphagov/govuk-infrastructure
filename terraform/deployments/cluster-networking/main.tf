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
      tags = ["cluster-networking", "aws"]
    }
  }

  required_version = "~> 1.15"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.81.0"
    }
    # The AWS provider is only used here for remote state in remote.tf. Please
    # do not add AWS resources to this module.
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.68.1"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "3.0.0-beta3"
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

provider "kubectl" {
  host                   = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_endpoint
  cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster_token.token
  load_config_file       = false
}
