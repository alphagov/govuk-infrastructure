resource "aws_iam_role" "eks_workers" {
  name = "eks_workers-tmp"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_workers.name
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_workers.name
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_workers.name
}


resource "aws_eks_node_group" "govuk" {
  cluster_name    = aws_eks_cluster.govuk.name
  node_group_name = "govuk"
  node_role_arn   = aws_iam_role.eks_workers.arn
  subnet_ids      = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids

  instance_types = [var.worker_node_instance_type]

  scaling_config {
    desired_size = var.desired_workers_size
    max_size     = var.desired_workers_size
    min_size     = var.desired_workers_size
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_AmazonEC2ContainerRegistryReadOnly,
    kubernetes_config_map.aws_auth,
  ]
}
