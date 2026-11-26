resource "aws_eks_access_entry" "creator" {
  cluster_name = aws_eks_cluster.this.name

  principal_arn = var.cluster_creator_principal_arn
  type          = "STANDARD"

}

resource "aws_eks_access_policy_association" "creator_policies" {
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    ="arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.cluster_creator_principal_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.creator]
}
