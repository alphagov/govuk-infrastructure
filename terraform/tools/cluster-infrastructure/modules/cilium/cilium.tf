resource "kubernetes_namespace_v1" "cilium" {
  metadata {
    name = "cilium"
  }
}

resource "helm_release" "cilium" {
  name      = "cilium"
  namespace = kubernetes_namespace_v1.cilium.metadata[0].name

  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.20.5"
  skip_crds  = true
  timeout    = 900

  values = [yamlencode({
    cni = {
      exclusive = false,

      chainingMode = "aws-cni"
    }
    enableIPv4Masquerade = false
    routingMode          = "native"
    hubble = {
      enabled = true
      metrics = {
        enableOpenMetrics = true
        enabled = [
          "dns",
          "drop",
          "tcp",
          "flow",
          "port-distribution",
          "icmp",
          "httpV2:exemplars=true;labelsContext=source_ip",
          "source_namespace",
          "source_workload",
          "destination_ip",
          "destination_namespace",
          "destination_workload",
          "traffic_direction"
        ]
      }
      serviceMonitor = {
        enabled = true
      }
      dashboards = {
        enabled = true
      }
      relay = {
        enabled  = true
        replicas = 2
      }
      ui = {
        enabled  = true
        replicas = 2
      }
    }
    prometheus = {
      metricsSservice = true
      enabled         = true
      serviceMonitor = {
        enabled        = true
        trustCRDsExist = true
      }
    }
    # this value is used to ensure Cilium does not make breaking changes
    # to our config. It should be kept as-is unless a pre-flight check
    # fails and we have to perform configuration changes for an upgrade
    # to succeed.
    upgradeCompatibility = "1.20"
  })]
}
