# The eks-stage2 module is responsible for Kubernetes objects within the EKS
# cluster.
#
# It has to be a separate root module (aka deployment/project) because
# Terraform does not handle dependencies in provider configurations, which
# means the Kubernetes and Helm providers cannot reliably be initialised in the
# same root module which creates the EKS cluster (see warning in
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources).

terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.33"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}
