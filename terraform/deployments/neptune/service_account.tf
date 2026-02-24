resource "kubernetes_service_account_v1" "this" {
  for_each = var.neptune_dbs
  metadata {
    name      = "${each.value.name}-neptune-db"
    namespace = local.apps_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role[each.key].arn
    }
    labels = {
      "app.kubernetes.io/instance" = "neptune"
    }
  }

  depends_on = [
    module.iam_assumable_role
  ]
}

resource "kubernetes_cluster_role_v1" "this" {
  for_each = var.neptune_dbs
  metadata {
    name = "${each.value.name}-neptune-db"
  }

  dynamic "rule" {
    for_each = each.value.serviceaccount_rules
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

resource "kubernetes_cluster_role_binding_v1" "this" {
  for_each = var.neptune_dbs

  metadata {
    name = "${each.value.name}-neptune-db"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.this[each.key].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.this[each.key].metadata[0].name
    namespace = local.apps_namespace
  }
}

