resource "helm_release" "pod_security_policy" {
  name       = "psp-baseline"
  chart      = "cluster-security"
  repository = "https://alphagov.github.io/govuk-helm-charts/"
  namespace  = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_services_namespace
}
