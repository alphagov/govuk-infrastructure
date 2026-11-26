variable "cluster_name" {
  type        = string
  description = "The id of the cluster to deploy infrastructure services to"
}

variable "kube_state_metrics_addon_version" {
  type        = string
  description = "The version to deploy for the kube state metrics addon"
}

variable "metrics_server_addon_version" {
  type        = string
  description = "The version to deploy for the metrics server addon"
}

variable "eks_pod_identity_agent_addon_version" {
  type        = string
  description = "The version to deploy for the eks pod identity agent addon"
}
