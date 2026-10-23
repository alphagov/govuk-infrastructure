resource "helm_release" "cilium" {
  chart = "cilium"
  name  = "cilium"

  namespace  = "kube-system"
  version    = "1.20.3"
  repository = "https://helm.cilium.io/"
  values = [yamlencode({
    "cni.chainingMode"    = "aws-cni",
    "cni.exclusive"       = false,
    enableIPv4Masquerade  = false,
    routingMode           = "native",
    autoDirectNodeRouting = true
  })]
}
