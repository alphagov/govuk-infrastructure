# this resource has an auto-generated name in
# integration, staging and production
resource "aws_iam_role" "node" {
  name                  = "${var.environment_name}-node-group"
  description           = "EKS managed node group IAM role"
  assume_role_policy    = data.aws_iam_policy_document.node_assumerole.json
  force_detach_policies = true
  lifecycle { ignore_changes = [name] }
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

resource "aws_iam_role_policy_attachment" "node" {
  for_each = toset([
    "AmazonEKSWorkerNodePolicy",
    "AmazonEKS_CNI_Policy",
    "AmazonSSMManagedInstanceCore",
  ])
  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
  role       = aws_iam_role.node.name
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
