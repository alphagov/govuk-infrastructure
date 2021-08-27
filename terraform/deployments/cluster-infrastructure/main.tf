# The cluster-infrastructure module is responsible for the AWS resources which
# constitute the EKS cluster.
#
# Any Kubernetes objects which need to be managed via Terraform belong in
# ../cluster-services, not in this module.
#
# See https://github.com/alphagov/govuk-infrastructure/blob/main/docs/architecture/decisions/0003-split-terraform-state-into-separate-aws-cluster-and-kubernetes-resource-phases.md

terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.33"
    }
  }
}

locals {
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
  version = "17.1.0"

  cluster_name     = var.cluster_name
  cluster_version  = "1.21"
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

  workers_group_defaults = {
    root_volume_type = "gp3"
    # TODO: remove this workaround for adding default tags to the ASG once
    # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1455
    # and https://github.com/hashicorp/terraform-provider-aws/issues/19204 are
    # fully resolved. local.default_tags can then be inlined in
    # provider.aws.default_tags.
    tags = [for k, v in local.default_tags : {
      key                 = k
      value               = v
      propagate_at_launch = true
    }]
  }

  worker_groups = [
    {
      asg_desired_capacity = var.workers_size_desired
      asg_max_size         = var.workers_size_max
      asg_min_size         = var.workers_size_min
      instance_type        = var.workers_instance_type
      subnets              = [for s in aws_subnet.eks_private : s.id]
      tags = [
        {
          key                 = "k8s.io/cluster-autoscaler/enabled"
          value               = "true"
          propagate_at_launch = false
        },
        {
          key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          value               = "owned"
          propagate_at_launch = false
        }
      ]
    }
  ]
}
