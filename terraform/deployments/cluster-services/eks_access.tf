
data "aws_iam_roles" "cluster-admin" { name_regex = "(^terraform-cloud$|\\..*-admin$|\\..*-fulladmin$)" }
data "aws_iam_roles" "developer" { name_regex = "\\..*-developer$" }

resource "aws_eks_access_entry" "cluster-admin" {
  for_each = data.aws_iam_roles.cluster-admin.arns

  cluster_name = local.cluster_name

  principal_arn     = each.value
  kubernetes_groups = ["cluster-admins"]
  type              = "STANDARD"
}

resource "aws_eks_access_entry" "developer" {
  for_each = data.aws_iam_roles.developer.arns

  cluster_name = local.cluster_name

  principal_arn     = each.value
  kubernetes_groups = ["developers"]
  type              = "STANDARD"
}

resource "kubernetes_cluster_role_binding" "cluster_admins" {
  metadata {
    name   = "cluster-admins"
    labels = { "app.kubernetes.io/managed-by" = "Terraform" }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "Group"
    name      = "cluster-admins"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role" "developer" {
  metadata {
    name   = "developer"
    labels = { "app.kubernetes.io/managed-by" = "Terraform" }
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "pods/logs", "services", "configmaps", "secrets", "endpoints", "events"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps", "batch"]
    resources  = ["deployments", "replicasets", "statefulsets", "jobs", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "developer" {
  metadata {
    name   = "developer-cluster-binding"
    labels = { "app.kubernetes.io/managed-by" = "Terraform" }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.developer.metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "developer"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role" "developer" {
  for_each = toset(["apps", "datagovuk", "licensify"])

  metadata {
    name      = "developer"
    namespace = each.key
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
  for_each   = toset(["apps", "datagovuk", "licensify"])
  depends_on = [kubernetes_role.developer]

  metadata {
    name      = "developer-binding"
    namespace = each.key
    labels    = { "app.kubernetes.io/managed-by" = "Terraform" }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.developer[each.key].metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "developer"
    api_group = "rbac.authorization.k8s.io"
  }
}
