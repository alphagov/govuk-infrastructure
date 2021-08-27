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

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      project              = "replatforming"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}

locals {
  cluster_name = "govuk"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.1.0"

  cluster_name     = local.cluster_name
  cluster_version  = "1.21"
  subnets          = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
  vpc_id           = data.terraform_remote_state.infra_networking.outputs.vpc_id
  enable_irsa      = true
  manage_aws_auth  = false
  write_kubeconfig = false

  # TODO: Tag the node pool ASG once
  # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1455 is
  # addressed. This may or may not involve passing additional args here.
  # Ideally the default_tags above would propagate automatically to the ASG but
  # that isn't possible yet because of the above bug and
  # https://github.com/hashicorp/terraform-provider-aws/issues/19204.

  cluster_log_retention_in_days = var.cluster_log_retention_in_days
  cluster_enabled_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]

  worker_groups = [
    {
      instance_type        = var.workers_instance_type
      asg_desired_capacity = var.workers_size_desired
      asg_max_size         = var.workers_size_max
      asg_min_size         = var.workers_size_min
      root_volume_type     = "gp3"
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "owned"
        }
      ]
    }
  ]
}
