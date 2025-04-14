data "aws_iam_roles" "developer" { name_regex = "\\..*-developer$" }

resource "kubernetes_role_binding" "poweruser" {
  depends_on = [kubernetes_namespace.datagovuk]

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

resource "kubernetes_role" "developer" {
  depends_on = [kubernetes_namespace.datagovuk]

  metadata {
    name      = "developer"
    namespace = var.datagovuk_namespace
    labels    = { "app.kubernetes.io/managed-by" = "Terraform" }
  }

  rule {
    api_groups = ["", "apps"]
    resources  = ["pods", "pods/logs", "deployments", "replicasets", "statefulsets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create"]
  }
}

resource "kubernetes_role_binding" "developer" {
  depends_on = [
    kubernetes_namespace.datagovuk,
    kubernetes_role.developer
  ]

  metadata {
    name      = "developer-binding"
    namespace = var.datagovuk_namespace
    labels    = { "app.kubernetes.io/managed-by" = "Terraform" }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.developer.metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "developer"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "aws_eks_access_policy_association" "developer" {
  for_each = data.aws_iam_roles.developer.arns

  cluster_name  = local.cluster_id
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = each.value

  access_scope {
    type       = "namespace"
    namespaces = ["datagovuk"]
  }
}
