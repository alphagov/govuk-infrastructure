resource "helm_release" "argo_bootstrap" {
  chart            = "argo-bootstrap"
  name             = "datagovuk-argo-bootstrap"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://alphagov.github.io/govuk-ckan-charts/"
  version          = "1.0.4" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    environment = var.govuk_environment
  })]
}
