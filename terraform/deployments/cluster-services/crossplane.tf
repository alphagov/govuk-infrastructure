resource "helm_release" "crossplane" {
  name             = "crossplane"
  repository       = "https://charts.crossplane.io"
  chart            = "crossplane"
  version          = "2.4.0-rc.0.223.g2d040d2da"
  namespace        = "crossplane-system"
  create_namespace = true
  timeout          = var.helm_timeout_seconds
}

