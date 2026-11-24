resource "helm_release" "cilium" {
  name             = "cilium"
  create_namespace = true

  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.20.5"

  values = [yamlencode({
    cni = {
      exclusive    = false,
      chainingMode = "aws-cni"
    }
    enableIPv4Masquerade = false
    routingMode          = "native"
    hubble = {
      enabled = true
      relay = {
        enabled  = true
        replicas = 2
      }
      ui = {
        enabled  = true
        replicas = 2
      }
    }
    # this value is used to ensure Cilium does not make breaking changes
    # to our config. It should be kept as-is unless a pre-flight check
    # fails and we have to perform configuration changes for an upgrade
    # to succeed.
    upgradeCompatibility = "1.20"
  })]

  depends_on = [aws_eks_cluster.this, aws_eks_addon.vpc_cni, aws_eks_node_group.workers]
}
