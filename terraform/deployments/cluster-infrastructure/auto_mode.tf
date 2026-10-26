data "aws_iam_policy_document" "auto_mode_node_class" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "auto_mode_node_class" {
  name                  = "${var.cluster_name}-auto-mode-node"
  description           = "EKS Auto Mode Node Class role"
  assume_role_policy    = data.aws_iam_policy_document.auto_mode_node_class.json
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "auto_mode_node_class" {
  for_each = toset([
    aws_iam_policy.pull_from_ecr.arn
  ])
  policy_arn = each.key
  role       = aws_iam_role.auto_mode_node_class.name
}

resource "aws_eks_access_entry" "auto_mode_node_class" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.auto_mode_node_class.arn
  type          = "EC2"
}

resource "aws_eks_access_policy_association" "auto_mode_node_class" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy"
  principal_arn = aws_iam_role.auto_mode_node_class.arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.auto_mode_node_class]
}