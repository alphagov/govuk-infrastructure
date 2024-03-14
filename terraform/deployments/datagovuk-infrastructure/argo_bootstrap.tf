resource "helm_release" "argo_bootstrap" {
  chart            = "argo-bootstrap"
  name             = "datagovuk-argo-bootstrap"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://alphagov.github.io/govuk-dgu-charts/"
  version          = "1.1.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    environment = var.govuk_environment
  })]
}
