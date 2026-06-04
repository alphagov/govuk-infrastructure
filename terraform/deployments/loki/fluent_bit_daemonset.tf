resource "kubernetes_namespace_v1" "fluent_bit" {
  metadata {
    name = "fluent-bit"
  }
}

locals {
  flb_helm_chart_values = templatefile(
    "./files/flb_helm_values.tpl.yaml", {}
  )
}

resource "helm_release" "fluent_bit_ds" {
  chart      = "fluent-bit-collector"
  name       = "fluent-bit-collector"
  namespace  = kubernetes_namespace_v1.fluent_bit.id
  repository = "https://fluent.github.io/helm-charts"
  version    = "1.0.6"
  timeout    = 300
  values     = [local.flb_helm_chart_values]
}

