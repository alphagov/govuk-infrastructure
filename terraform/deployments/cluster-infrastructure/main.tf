# The cluster-infrastructure module is responsible for the AWS resources which
# constitute the EKS cluster.
#
# Any Kubernetes objects which need to be managed via Terraform belong in
# ../cluster-services, not in this module.
#
# See https://github.com/alphagov/govuk-infrastructure/blob/main/docs/architecture/decisions/0003-split-terraform-state-into-separate-aws-cluster-and-kubernetes-resource-phases.md

terraform {
  backend "s3" {}

  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

locals {
  cluster_services_namespace = "cluster-services"
  secrets_prefix             = "govuk"

  # module.eks.cluster_oidc_issuer_url is a full URL, e.g.
  # "https://oidc.eks.eu-west-1.amazonaws.com/id/B4378A8EBD334FEEFDF3BCB6D0E612C6"
  # but the string to which IAM compares this lacks the protocol part, so we
  # have to strip the "https://" when we construct the trust policy
  # (assume-role policy).
  cluster_oidc_issuer = replace(module.eks.cluster_oidc_issuer_url, "https://", "")

  default_tags = {
    cluster              = var.cluster_name
    project              = "replatforming"
    repository           = "govuk-infrastructure"
    terraform_deployment = basename(abspath(path.root))
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags { tags = local.default_tags }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.20.0"

  cluster_name     = var.cluster_name
  cluster_version  = var.cluster_version
  subnets          = [for s in aws_subnet.eks_control_plane : s.id]
  vpc_id           = data.terraform_remote_state.infra_vpc.outputs.vpc_id
  enable_irsa      = true
  manage_aws_auth  = false
  write_kubeconfig = false

  cluster_endpoint_private_access = true
  cluster_log_retention_in_days   = var.cluster_log_retention_in_days
  cluster_enabled_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]

  node_groups_defaults = {
    # TODO: remove this workaround for adding default tags to node ASGs once
    # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1455
    # and https://github.com/hashicorp/terraform-provider-aws/issues/19204 are
    # fully resolved. local.default_tags can then be inlined in
    # provider.aws.default_tags.
    additional_tags = local.default_tags
    capacity_type   = var.workers_default_capacity_type
    disk_size       = 50 # GB
    subnets         = [for s in aws_subnet.eks_private : s.id]
  }

  node_groups = [
    {
      desired_capacity = var.workers_size_desired
      max_capacity     = var.workers_size_max
      min_capacity     = var.workers_size_min
      version          = var.cluster_version
      instance_types   = var.workers_instance_types
      additional_tags = {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }
    }
  ]
}

# TODO: move these into module.eks once it supports cluster addons, i.e. once
# https://github.com/terraform-aws-modules/terraform-aws-eks/pull/1443 is
# merged.
resource "aws_eks_addon" "cluster_addons" {
  for_each          = toset(["coredns", "kube-proxy", "vpc-cni"])
  addon_name        = each.key
  addon_version     = lookup(var.cluster_addon_versions, each.key, null)
  cluster_name      = module.eks.cluster_id
  resolve_conflicts = "OVERWRITE"
}
