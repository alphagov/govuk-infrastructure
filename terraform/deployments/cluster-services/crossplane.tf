resource "helm_release" "crossplane" {
  name             = "crossplane"
  repository       = "https://charts.crossplane.io/stable"
  chart            = "crossplane-stable"
  version          = "2.3.4"
  namespace        = "crossplane-system"
  create_namespace = true
  timeout          = var.helm_timeout_seconds
}

