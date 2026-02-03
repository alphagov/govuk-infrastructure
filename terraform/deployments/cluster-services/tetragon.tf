resource "helm_release" "tetragon" {
  name       = "tetragon"
  repository = "https://helm.cilium.io"
  chart      = "tetragon"
  version    = "1.6.0"
  namespace  = "kube-system"

  values = [yamlencode({})]
}

