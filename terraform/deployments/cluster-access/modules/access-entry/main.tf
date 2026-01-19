locals {
  namespace_role_rules = concat(
    [],
    var.namespace_role_rules
  )
  cluster_role_rules = concat(
    [
      {
        api_groups = [""],
        resources  = ["namespaces"],
        verbs      = ["get", "list", "watch"]
      }
    ],
    var.cluster_role_rules
  )
}

data "aws_iam_roles" "roles" {
  name_regex = "\\..*-${var.name}$"
}

resource "aws_eks_access_entry" "entry" {
  for_each = data.aws_iam_roles.roles.arns

  cluster_name = var.cluster_name

  principal_arn     = each.value
  kubernetes_groups = [var.name]
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "entry" {
  for_each = data.aws_iam_roles.roles.arns

  cluster_name  = var.cluster_name
  policy_arn    = var.access_policy_arn
  principal_arn = each.value

  dynamic "access_scope" {
    for_each = var.access_policy_scope == "namespace" ? [1] : []
    content {
      type       = "namespace"
      namespaces = var.access_policy_namespaces
    }
  }

  dynamic "access_scope" {
    for_each = var.access_policy_scope == "cluster" ? [1] : []
    content {
      type = "cluster"
    }
  }

  depends_on = [aws_eks_access_entry.entry]
}

resource "kubernetes_cluster_role_v1" "cluster_role" {
  metadata {
    name   = var.name
    labels = { "app.kubernetes.io/managed-by" = "Terraform" }
  }

  dynamic "rule" {
    for_each = toset(local.cluster_role_rules)

    content {
      api_groups = rule.key.api_groups
      resources  = rule.key.resources
      verbs      = rule.key.verbs
    }
  }
}

resource "kubernetes_cluster_role_binding_v1" "cluster_role" {
  metadata {
    name   = "${var.name}-binding"
    labels = { "app.kubernetes.io/managed-by" = "Terraform" }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.cluster_role.metadata[0].name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = var.name
  }

  depends_on = [kubernetes_cluster_role_v1.cluster_role]
}

resource "kubernetes_role_v1" "namespace_role" {
  for_each = toset(var.access_policy_namespaces)

  metadata {
    name      = var.name
    namespace = each.key
    labels    = { "app.kubernetes.io/managed-by" = "Terraform" }
  }

  dynamic "rule" {
    for_each = toset(local.namespace_role_rules)

    content {
      api_groups = rule.key.api_groups
      resources  = rule.key.resources
      verbs      = rule.key.verbs
    }
  }
}

resource "kubernetes_role_binding_v1" "namespace_role" {
  for_each = toset(var.access_policy_namespaces)

  metadata {
    name      = "${var.name}-binding"
    namespace = each.key
    labels    = { "app.kubernetes.io/managed-by" = "Terraform" }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = var.name
  }

  subject {
    kind      = "Group"
    name      = var.name
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [kubernetes_role_v1.namespace_role]
}
