locals {

  managed_node_group_defaults = {
    capacity_type                  = "ON_DEMAND"
    enable_monitoring              = true
    use_latest_ami_release_version = false
    metadata_options = {
      http_put_response_hop_limit = 2
    }
  }

  managed_node_group_blue = {
    blue = merge(
      local.managed_node_group_defaults,
      {
        ami_type       = var.blue_node_group_config.ami_type
        name_prefix    = "${var.environment_name}-blue"
        desired_size   = var.blue_node_group_config.desired_size
        max_size       = var.blue_node_group_config.max_size
        min_size       = var.blue_node_group_config.min_size
        instance_types = var.blue_node_group_config.instance_types
        update_config  = { max_unavailable = 1 }
        additional_tags = {
          "k8s.io/cluster-autoscaler/enabled"                 = "true"
          "k8s.io/cluster-autoscaler/${var.environment_name}" = "owned"
        }
      }
    )
  }

  # This will be a "Green" Node Group once Blue has become primary
  managed_node_group_green = {
    green = merge(
      local.managed_node_group_defaults,
      {
        ami_type       = var.green_node_group_config.ami_type
        name_prefix    = "${var.environment_name}-green"
        desired_size   = var.green_node_group_config.desired_size
        max_size       = var.green_node_group_config.max_size
        min_size       = var.green_node_group_config.min_size
        instance_types = var.green_node_group_config.instance_types
        update_config  = { max_unavailable = 1 }
        additional_tags = {
          "k8s.io/cluster-autoscaler/enabled"                 = "true"
          "k8s.io/cluster-autoscaler/${var.environment_name}" = "owned"
        }
      }
    )
  }


  eks_managed_node_groups = merge(var.blue_node_group_config.enabled ? local.managed_node_group_blue : {}, var.green_node_group_config.enabled ? local.managed_node_group_green : {})

}

resource "aws_iam_role" "node" {
  name                  = "${var.environment_name}-node-group"
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
  name        = "${var.environment_name}-pull-from-ecr"
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

resource "aws_eks_node_group" "workers" {
  for_each               = local.eks_managed_node_groups
  cluster_name           = aws_eks_cluster.this.name
  node_group_name_prefix = each.key

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.default_version
  }

  node_role_arn = aws_iam_role.node.arn
  subnet_ids    = var.vpc_config.node_private_subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  update_config {
    max_unavailable = each.value.update_config.max_unavailable
  }

  region         = var.region
  ami_type       = each.value.ami_type
  capacity_type  = each.value.capacity_type
  instance_types = each.value.instance_types

  release_version = false

  taint {
    key    = "node.cilium.io/agent-not-ready"
    value  = "true"
    effect = "NO_EXECUTE"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.pull_from_ecr,
    aws_iam_role_policy_attachment.node,
  ]

  lifecycle {
    create_before_destroy = true
  }
}
