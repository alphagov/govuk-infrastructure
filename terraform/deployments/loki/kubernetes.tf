resource "kubernetes_namespace_v1" "loki" {
  metadata {
    name = "loki"
  }
}
