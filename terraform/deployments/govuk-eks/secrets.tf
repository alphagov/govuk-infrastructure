resource "kubernetes_service_account" "signon-secrets-management" {
  metadata {
    name = "signon-secrets-management"
  }
}

resource "kubernetes_cluster_role" "signon-secrets-management-role" {
  metadata {
    name = "signon-secrets-management"
  }

  rule {
    api_groups = ["", ]
    resources  = ["secrets"]
    verbs      = ["create", "get", "list", "update", "watch", "patch"]
  }
}

resource "kubernetes_cluster_role_binding" "signon-secrets-management-role-binding" {
  metadata {
    name = "signon-secrets-management"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.signon-secrets-management-role.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.signon-secrets-management.metadata.0.name
    namespace = "default"
  }
}
