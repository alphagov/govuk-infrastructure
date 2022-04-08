resource "helm_release" "fastly-exporter" {
  chart            = "fastly-exporter"
  name             = "fastly-exporter"
  namespace        = local.monitoring_ns
  create_namespace = true
  repository       = "https://alphagov.github.io/govuk-helm-charts/"
}
