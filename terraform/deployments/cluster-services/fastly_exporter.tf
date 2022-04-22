resource "helm_release" "fastly-exporter" {
  name             = "fastly-exporter"
  repository       = "https://alphagov.github.io/govuk-helm-charts/"
  chart            = "fastly-exporter"
  version          = "0.1.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.monitoring_ns
  create_namespace = true
}
