resource "helm_release" "kyverno" {
  # ONLY install if the environment is integration
  count = var.govuk_environment == "integration" ? 1 : 0

  name             = "kyverno"
  repository       = "https://kyverno.github.io/kyverno/"
  chart            = "kyverno"
  namespace        = "kyverno"
  create_namespace = true

  version = "3.8.1"
}

resource "kubernetes_namespace_v1" "sigstore_test" {
  count = var.govuk_environment == "integration" ? 1 : 0

  metadata {
    name = "sigstore-test"
  }
}

resource "kubernetes_config_map_v1_data" "argocd_kyverno_health_check" {
  count = var.govuk_environment == "integration" ? 1 : 0

  metadata {
    name      = "argocd-cm"
    namespace = local.services_ns
  }

  data = {
    "resource.customizations.health.kyverno.io_Policy" = <<-EOT
      hs = {}
      hs.status = "Progressing"
      hs.message = "Waiting for policy to be ready"
      if obj.status ~= nil and obj.status.ready ~= nil then
        if obj.status.ready == true then
          hs.status = "Healthy"
          hs.message = "Policy is ready"
        else
          hs.status = "Degraded"
          hs.message = "Policy is not ready"
        end
      end
      return hs
    EOT
  }

  force = true # Ensures Terraform can overwrite the key if it already exists
}
