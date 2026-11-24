resource "aws_eks_cluster" "this" {
  name = var.environment_name

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  role_arn = aws_iam_role.this.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids             = var.vpc_config.control_plane_subnet_ids
    endpoint_public_access = true
  }

  bootstrap_self_managed_addons = false
  deletion_protection           = var.deletion_protection
  enabled_cluster_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]

  encryption_config {
    provider {
      key_arn = aws_kms_key.cluster.arn
    }

    resources = ["secrets"]
  }

  region = var.region

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy,
    aws_iam_role_policy_attachment.amazon_vpc_resource_controller
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "this" {
  name = "${var.environment_name}-eks-cluster"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.this.name
}


resource "aws_iam_role_policy_attachment" "amazon_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.this.name
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_eks_cluster_auth" "auth" {
  name = aws_eks_cluster.this.name
}