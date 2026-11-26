module "cluster_crds" {
  source = "./modules/cluster-crds"

  prometheus_operator_crd_version = "v0.95.2"
  cilium_crd_version              = "v1.20.5"
}

module "cluster_networking" {
  source = "./modules/cluster-networking"

  cluster_name                         = data.tfe_outputs.cluster_init.nonsensitive_values.cluster_name
  coredns_addon_version                = "v1.14.7-eksbuild.35"
  kube_state_metrics_addon_version     = "v2.20.0-eksbuild.10"
  metrics_server_addon_version         = "v0.9.1-eksbuild.2"
  eks_pod_identity_agent_addon_version = "v1.4.1-eksbuild.3"

  depends_on = [module.cluster_crds]
}

module "cluster_access" {
  source = "./modules/cluster-access"

  cluster_name = data.tfe_outputs.cluster_init.nonsensitive_values.cluster_name
}
