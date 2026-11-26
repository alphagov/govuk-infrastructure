resource "aws_eks_addon" "kube_state_metrics" {
  cluster_name                = var.cluster_name
  addon_name                  = "kube-state-metrics"
  addon_version               = var.kube_state_metrics_addon_version
  configuration_values        = null
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "metrics_server" {
  cluster_name                = var.cluster_name
  addon_name                  = "metrics-server"
  addon_version               = var.metrics_server_addon_version
  configuration_values        = null
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "eks_pod_identity_agent" {
  cluster_name                = var.cluster_name
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = var.eks_pod_identity_agent_addon_version
  configuration_values        = null
  resolve_conflicts_on_update = "OVERWRITE"
}

