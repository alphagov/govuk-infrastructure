variable "component_versions" {
  description = "Version strings for each third-party component deployed to a Kubernetes cluster in this repository"
  type = object({
    // EKS addons
    coredns_addon                  = string
    eks_pod_identity_agent_addon   = string
    kube_proxy_addon               = string
    kube_state_metrics_addon       = string
    metrics_server_addon           = string
    network_flow_agent_addon_addon = string
    vpc_cni_addon                  = string

    // Helm charts
    argo_workflows_helm_chart             = string
    argocd_bootstrap_ephemeral_helm_chart = string
    argocd_bootstrap_helm_chart           = string
    argocd_helm_chart                     = string
    aws_ebs_csi_driver_helm_chart         = string
    aws_lb_controller_helm_chart          = string
    cilium_helm_chart                     = string
    cluster_secret_store_helm_chart       = string
    cluster_secrets_helm_chart            = string
    dex_helm_chart                        = string
    external_dns_helm_chart               = string
    external_secrets_helm_chart           = string
    filebeat_helm_chart                   = string
    fluent_bit_helm_chart                 = string
    gatekeeper_helm_chart                 = string
    kubernetes_events_shipper_helm_chart  = string


  })
}
