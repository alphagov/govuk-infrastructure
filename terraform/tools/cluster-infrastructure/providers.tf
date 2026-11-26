terraform {
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["cluster-infrastructure", "tools", "concourse"]
    }
  }
  required_version = "~> 1.17"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.54.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "3.0.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.14.2"
    }
  }
}


provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      product              = "govuk"
      system               = "govuk-platform-engineering"
      service              = "eks"
      environment          = "tools"
      owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform-deployment = basename(abspath(path.root))
    }
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.tfe_outputs.cluster_init.nonsensitive_values.cluster_name
}

provider "kubernetes" {
  host = data.tfe_outputs.cluster_init.nonsensitive_values.cluster_endpoint

  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_init.nonsensitive_values.cluster_ca_base64)

}

provider "kubectl" {
  host = data.tfe_outputs.cluster_init.nonsensitive_values.cluster_endpoint

  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_init.nonsensitive_values.cluster_ca_base64)
  load_config_file       = false
}


provider "helm" {
  kubernetes = {
    host = data.tfe_outputs.cluster_init.nonsensitive_values.cluster_endpoint

    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.tfe_outputs.cluster_init.nonsensitive_values.cluster_ca_base64)
  }
}

