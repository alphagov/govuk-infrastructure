# NOTE: coredns addon and cilium need to come up in parallel b/c they have cyclical dependencies
resource "aws_eks_addon" "coredns" {
  cluster_name                = var.cluster_name
  addon_name                  = "coredns"
  addon_version               = var.coredns_addon_version
  configuration_values        = null
  resolve_conflicts_on_update = "OVERWRITE"
}

module "cilium" {
  source = "../cilium"
}


module "post_compute_cluster_addons" {
  source = "../eks_addons"

  cluster_name                         = var.cluster_name
  kube_state_metrics_addon_version     = "v2.20.0-eksbuild.10"
  metrics_server_addon_version         = "v0.9.1-eksbuild.2"
  eks_pod_identity_agent_addon_version = "v1.4.1-eksbuild.3"

  depends_on = [module.cilium]
}
