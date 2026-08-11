resource "helm_release" "crossplane" {
  name             = "crossplane"
  repository       = "https://charts.crossplane.io/stable"
  chart            = "crossplane"
  version          = "2.4.0"
  namespace        = "crossplane-system"
  create_namespace = true
  timeout          = var.helm_timeout_seconds
}

