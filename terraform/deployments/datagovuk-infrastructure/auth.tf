resource "kubernetes_role_binding" "poweruser" {
  metadata {
    name      = "poweruser-${var.datagovuk_namespace}"
    namespace = var.datagovuk_namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "poweruser"
  }
  subject {
    kind      = "Group"
    name      = "powerusers"
    api_group = "rbac.authorization.k8s.io"
  }
}
