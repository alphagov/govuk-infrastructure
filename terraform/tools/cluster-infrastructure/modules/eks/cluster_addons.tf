resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "coredns"
  addon_version               = "v1.14.7-eksbuild.35"
  configuration_values        = null
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.workers, helm_release.cilium]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.36.0-eksbuild.65"
  configuration_values        = null
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.workers, helm_release.cilium]
}

resource "aws_eks_addon" "kube_state_metrics" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "kube-state-metrics"
  addon_version               = "v2.20.0-eksbuild.10"
  configuration_values        = null
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.workers, helm_release.cilium]
}

resource "aws_eks_addon" "metrics_server" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "metrics-server"
  addon_version               = "v0.9.1-eksbuild.2"
  configuration_values        = null
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.workers, helm_release.cilium]
}

resource "aws_eks_addon" "eks_pod_identity_agent" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = "v1.4.1-eksbuild.3"
  configuration_values        = null
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.workers]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.23.3-eksbuild.1"
  configuration_values        = jsonencode({ enableNetworkPolicy = "true" })
  resolve_conflicts_on_update = "OVERWRITE"
}
