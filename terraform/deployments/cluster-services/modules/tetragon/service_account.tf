resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = local.sa_name
    namespace = local.logging_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role.arn
    }
    labels = {
      "app.kubernetes.io/instance" = "fluent-bit"
    }
  }

  depends_on = [
    module.iam_assumable_role
  ]
}

resource "kubernetes_cluster_role_v1" "this" {
  metadata {
    name = local.sa_name
  }

  dynamic "rule" {
    for_each = local.serviceaccount_rules
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

resource "kubernetes_cluster_role_binding_v1" "this" {
  metadata {
    name = local.sa_name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.this.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.this.metadata[0].name
    namespace = local.logging_namespace
  }
}

