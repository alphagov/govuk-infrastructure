# The cluster-infrastructure module is responsible for the AWS resources which
# constitute the EKS cluster.
#
# Any Kubernetes objects which need to be managed via Terraform belong in
# ../cluster-services, not in this module.
#
# See https://github.com/alphagov/govuk-infrastructure/blob/main/docs/architecture/decisions/0003-split-terraform-state-into-separate-aws-cluster-and-kubernetes-resource-phases.md

terraform {
  # backend "s3" {}
  cloud {
    organization = "govuk"
    workspaces {
      tags = ["cluster-infrastructure", "eks", "aws"]
    }
  }
  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  cluster_services_namespace = "cluster-services"
  secrets_prefix             = "govuk"
  monitoring_namespace       = "monitoring"
  node_security_group_id     = module.eks.cluster_primary_security_group_id
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      cluster              = var.cluster_name
      project              = "replatforming"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = [for s in aws_subnet.eks_control_plane : s.id]
  vpc_id          = data.terraform_remote_state.infra_vpc.outputs.vpc_id

  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  cluster_endpoint_public_access         = true
  cloudwatch_log_group_retention_in_days = var.cluster_log_retention_in_days
  cluster_enabled_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]

  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }
  create_kms_key = false

  # We're just using the cluster primary SG as created by EKS.
  create_cluster_security_group = false
  create_node_security_group    = false

  eks_managed_node_group_defaults = {
    ami_type              = "AL2_x86_64"
    capacity_type         = var.workers_default_capacity_type
    subnet_ids            = [for s in aws_subnet.eks_private : s.id]
    create_security_group = false
  }

  eks_managed_node_groups = {
    main = {
      name_prefix = var.cluster_name
      # TODO: set iam_role_permissions_boundary
      # TODO: apply provider default_tags to instances; might need to set launch_template_tags.
      desired_size               = var.workers_size_desired
      max_size                   = var.workers_size_max
      min_size                   = var.workers_size_min
      instance_types             = var.workers_instance_types
      disk_size                  = var.node_disk_size
      use_custom_launch_template = false
      update_config              = { max_unavailable = 1 }
      additional_tags = {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }
    }
  }
}

# Allow us to connect to nodes using AWS Systems Manager Session Manager.
resource "aws_iam_role_policy_attachment" "node_ssm" {
  role       = module.eks.eks_managed_node_groups["main"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
