# The cluster-infrastructure module is responsible for the AWS resources which
# constitute the EKS cluster.
#
# Any Kubernetes objects which need to be managed via Terraform belong in
# ../cluster-services, not in this module.
#
# See https://github.com/alphagov/govuk-infrastructure/blob/main/docs/architecture/decisions/0003-split-terraform-state-into-separate-aws-cluster-and-kubernetes-resource-phases.md

terraform {
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

  main_managed_node_group = {
    main = {
      name_prefix = var.cluster_name
      # TODO: set iam_role_permissions_boundary
      # TODO: apply provider default_tags to instances; might need to set launch_template_tags.
      desired_size   = var.workers_size_desired
      max_size       = var.workers_size_max
      min_size       = var.workers_size_min
      instance_types = var.workers_instance_types
      update_config  = { max_unavailable = 1 }
      # TODO(#1201): remove disk_size and use_custom_launch_template after AL2023 rollout.
      use_custom_launch_template = var.govuk_environment != "production"
      disk_size                  = var.node_disk_size
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.node_disk_size
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
      additional_tags = {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }
    }
  }

  arm_managed_node_group = {
    arm = {
      ami_type              = "AL2023_ARM_64_STANDARD"
      name_prefix           = var.cluster_name
      desired_size          = var.arm_workers_size_desired
      max_size              = var.arm_workers_size_max
      min_size              = var.arm_workers_size_min
      instance_types        = var.arm_workers_instance_types
      update_config         = { max_unavailable = 1 }
      block_device_mappings = local.main_managed_node_group.main.block_device_mappings
      taints = {
        arch = {
          key    = "arch"
          value  = "arm64"
          effect = "NO_SCHEDULE"
        }
      }
      additional_tags = {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }
    }
  }

  eks_managed_node_groups = merge(local.main_managed_node_group, var.enable_arm_workers ? local.arm_managed_node_group : {})
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Product              = "GOV.UK"
      System               = "EKS cluster infrastructure"
      Environment          = var.govuk_environment
      Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      cluster              = var.cluster_name
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}

data "aws_iam_policy_document" "node_assumerole" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  description           = "EKS managed node group IAM role"
  assume_role_policy    = data.aws_iam_policy_document.node_assumerole.json
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = toset([
    "AmazonEKSWorkerNodePolicy",
    "AmazonEC2ContainerRegistryReadOnly",
    "AmazonEKS_CNI_Policy",
    "AmazonSSMManagedInstanceCore",
  ])
  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
  role       = aws_iam_role.node.name
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

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
  create_kms_key                = false
  kms_key_enable_default_policy = false

  # We're just using the cluster primary SG as created by EKS.
  create_cluster_security_group = false
  create_node_security_group    = false

  authentication_mode = "CONFIG_MAP"

  eks_managed_node_group_defaults = {
    ami_type = (
      var.govuk_environment != "production"
      ? "AL2023_x86_64_STANDARD"
      : "AL2_x86_64"
    )
    capacity_type         = var.workers_default_capacity_type
    subnet_ids            = [for s in aws_subnet.eks_private : s.id]
    create_security_group = false
    create_iam_role       = false
    iam_role_arn          = aws_iam_role.node.arn
  }

  eks_managed_node_groups = local.eks_managed_node_groups
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
