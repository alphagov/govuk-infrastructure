resource "helm_release" "argo_bootstrap" {
  chart            = "argo-bootstrap"
  name             = "datagovuk-argo-bootstrap"
  namespace        = local.services_ns
  create_namespace = true
  repository       = "https://alphagov.github.io/govuk-dgu-charts/"
  version          = "1.2.0" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    environment = var.govuk_environment
  })]
}

resource "kubernetes_namespace" "datagovuk" {
  metadata {
    name = var.datagovuk_namespace
    annotations = {
      "argocd.argoproj.io/sync-options" = "ServerSideApply=true"
    }
    labels = {
      "app.kubernetes.io/managed-by"       = "Terraform"
      "argocd.argoproj.io/managed-by"      = "cluster-services"
      "pod-security.kubernetes.io/audit"   = "restricted"
      "pod-security.kubernetes.io/enforce" = "restricted"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }
  }
}
