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
