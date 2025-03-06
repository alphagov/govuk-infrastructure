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
  required_version = "~> 1.10"
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

  default_cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  metrics_server_addon = {
    metrics-server = { most_recent = true }
  }

  enabled_cluster_addons = merge(local.default_cluster_addons, var.enable_metrics_server ? local.metrics_server_addon : {})

  main_managed_node_group = {
    main = {
      name_prefix = var.cluster_name
      # TODO: set iam_role_permissions_boundary
      # TODO: apply provider default_tags to instances; might need to set launch_template_tags.
      desired_size   = var.x86_workers_size_desired
      max_size       = var.x86_workers_size_max
      min_size       = var.x86_workers_size_min
      instance_types = var.main_workers_instance_types
      update_config  = { max_unavailable = 1 }
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

  x86_managed_node_group = {
    x86 = {
      name_prefix = var.cluster_name
      # TODO: set iam_role_permissions_boundary
      # TODO: apply provider default_tags to instances; might need to set launch_template_tags.
      desired_size   = var.x86_workers_size_desired
      max_size       = var.x86_workers_size_max
      min_size       = var.x86_workers_size_min
      instance_types = var.x86_workers_instance_types
      update_config  = { max_unavailable = 1 }
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
      block_device_mappings = local.x86_managed_node_group.x86.block_device_mappings
      additional_tags = {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }
    }
  }

  eks_managed_node_groups = merge(var.enable_main_workers ? local.main_managed_node_group : {}, var.enable_x86_workers ? local.x86_managed_node_group : {}, var.enable_arm_workers ? local.arm_managed_node_group : {})
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

# this resource has an auto-generated name in
# integration, staging and production
resource "aws_iam_role" "node" {
  name                  = "${var.cluster_name}-node-group"
  description           = "EKS managed node group IAM role"
  assume_role_policy    = data.aws_iam_policy_document.node_assumerole.json
  force_detach_policies = true
  lifecycle { ignore_changes = [name] }
}

data "aws_iam_policy_document" "pull_from_ecr" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:BatchImportUpstreamImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings"
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "pull_from_ecr" {
  name        = "${var.cluster_name}-pull-from-ecr"
  description = "Policy to allows EKS to pull images from ECR"
  policy      = data.aws_iam_policy_document.pull_from_ecr.json
}

resource "aws_iam_role_policy_attachment" "pull_from_ecr" {
  policy_arn = aws_iam_policy.pull_from_ecr.arn
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = toset([
    "AmazonEKSWorkerNodePolicy",
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
  vpc_id          = data.tfe_outputs.vpc.nonsensitive_values.id

  cluster_addons = local.enabled_cluster_addons

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

  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_group_defaults = {
    ami_type              = "AL2023_x86_64_STANDARD"
    capacity_type         = var.x86_workers_default_capacity_type
    subnet_ids            = [for s in aws_subnet.eks_private : s.id]
    create_security_group = false
    create_iam_role       = false
    iam_role_arn          = aws_iam_role.node.arn
  }

  eks_managed_node_groups = local.eks_managed_node_groups
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key (${var.cluster_name})"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
