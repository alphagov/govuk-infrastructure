resource "helm_release" "fastly-exporter" {
  depends_on       = [helm_release.kube_prometheus_stack]
  name             = "fastly-exporter"
  repository       = "https://alphagov.github.io/govuk-helm-charts/"
  chart            = "fastly-exporter"
  version          = "0.1.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.monitoring_ns
  create_namespace = true
  values = [yamlencode({
    replicaCount = var.desired_ha_replicas
  })]
}
