resource "helm_release" "kubernetes_events_shipper" {
  count = var.ship_kubernetes_events_to_logit ? 1 : 0

  depends_on = [helm_release.cluster_secrets]

  chart      = "kubernetes-events-shipper"
  name       = "kubernetes-events-shipper"
  namespace  = local.services_ns
  repository = "https://alphagov.github.io/govuk-helm-charts/"
  version    = "1.0.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  timeout    = var.helm_timeout_seconds
}
