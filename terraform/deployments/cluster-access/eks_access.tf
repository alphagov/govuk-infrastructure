
data "aws_iam_roles" "cluster-admin" { name_regex = "(\\..*-fulladmin$|\\..*-platformengineer$)" }
data "aws_iam_roles" "developer" { name_regex = "\\..*-developer$" }
data "aws_iam_roles" "licensing" { name_regex = "\\..*-licensinguser$" }
data "aws_iam_roles" "readonly" { name_regex = "\\..*-readonly$" }
data "aws_iam_roles" "ithctester" { name_regex = "\\..*-ithctester$" }

locals {
  developer_namespaces = ["apps", "datagovuk", "licensify"]
}

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

resource "aws_eks_access_entry" "licensing" {
  for_each = data.aws_iam_roles.licensing.arns

  cluster_name = local.cluster_name

  principal_arn     = each.value
  kubernetes_groups = ["licensing"]
  type              = "STANDARD"
}

resource "aws_eks_access_entry" "readonly" {
  for_each = data.aws_iam_roles.readonly.arns

  cluster_name = local.cluster_name

  principal_arn     = each.value
  kubernetes_groups = ["readonly"]
  type              = "STANDARD"
}

resource "aws_eks_access_entry" "ithctester" {
  for_each = data.aws_iam_roles.ithctester.arns

  cluster_name = local.cluster_name

  principal_arn     = each.value
  kubernetes_groups = ["ithctester"]
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "cluster_admin" {
  for_each = data.aws_iam_roles.cluster-admin.arns

  cluster_name  = local.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.cluster-admin
  ]
}

resource "aws_eks_access_policy_association" "developer" {
  for_each = data.aws_iam_roles.developer.arns

  cluster_name  = local.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = each.value

  access_scope {
    type       = "namespace"
    namespaces = local.developer_namespaces
  }

  depends_on = [
    aws_eks_access_entry.developer
  ]
}

resource "aws_eks_access_policy_association" "licensing" {
  for_each = data.aws_iam_roles.licensing.arns

  cluster_name  = local.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = each.value

  access_scope {
    type       = "namespace"
    namespaces = ["licensify"]
  }

  depends_on = [
    aws_eks_access_entry.licensing
  ]
}

resource "aws_eks_access_policy_association" "readonly" {
  for_each = data.aws_iam_roles.readonly.arns

  cluster_name  = local.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = each.value

  access_scope {
    type       = "namespace"
    namespaces = local.developer_namespaces
  }

  depends_on = [
    aws_eks_access_entry.readonly
  ]
}

resource "aws_eks_access_policy_association" "ithctester" {
  for_each = data.aws_iam_roles.ithctester.arns

  cluster_name  = local.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.ithctester
  ]
}

resource "kubernetes_cluster_role_binding_v1" "cluster_admins" {
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

resource "kubernetes_cluster_role_v1" "developer" {
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

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
}


resource "kubernetes_cluster_role_binding_v1" "developer" {
  metadata {
    name   = "developer-cluster-binding"
    labels = { "app.kubernetes.io/managed-by" = "Terraform" }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.developer.metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "developers"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role_v1" "developer" {
  for_each = toset(local.developer_namespaces)

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

resource "kubernetes_role_binding_v1" "developer" {
  for_each   = toset(local.developer_namespaces)
  depends_on = [kubernetes_role_v1.developer]

  metadata {
    name      = "developer-binding"
    namespace = each.key
    labels    = { "app.kubernetes.io/managed-by" = "Terraform" }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "developer"
  }
  subject {
    kind      = "Group"
    name      = "developer"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role_v1" "licensing" {
  metadata {
    name      = "licensing"
    namespace = "licensify"
    labels    = { "app.kubernetes.io/managed-by" = "Terraform" }
  }

  rule {
    api_groups = ["", "apps"]
    resources  = ["pods", "pods/logs", "deployments", "replicasets", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create"]
  }
}

resource "kubernetes_role_binding_v1" "licensing" {
  depends_on = [kubernetes_role_v1.licensing]

  metadata {
    name      = "licensing-binding"
    namespace = "licensify"
    labels    = { "app.kubernetes.io/managed-by" = "Terraform" }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "licensing"
  }
  subject {
    kind      = "Group"
    name      = "licensing"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role_v1" "readonly" {
  metadata {
    name   = "readonly"
    labels = { "app.kubernetes.io/managed-by" = "Terraform" }
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "pods/logs", "services", "configmaps", "endpoints", "events"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["list"]
  }

  rule {
    api_groups = ["apps", "batch"]
    resources  = ["deployments", "replicasets", "statefulsets", "jobs", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
}


resource "kubernetes_cluster_role_binding_v1" "readonly" {
  metadata {
    name   = "readonly-cluster-binding"
    labels = { "app.kubernetes.io/managed-by" = "Terraform" }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.readonly.metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "readonly"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role_v1" "ithctester" {
  metadata {
    name   = "ithctester"
    labels = { "app.kubernetes.io/managed-by" = "Terraform" }
  }

  # Grant read-only access to certain custom resources
  rule {
    api_groups = ["argoproj.io", "external-secrets.io"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }

}

resource "kubernetes_cluster_role_binding_v1" "ithctester" {
  metadata {
    name   = "ithctester-cluster-binding"
    labels = { "app.kubernetes.io/managed-by" = "Terraform" }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.ithctester.metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "ithctester"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role_v1" "readonly" {
  for_each = toset(local.developer_namespaces)

  metadata {
    name      = "readonly"
    namespace = each.key
    labels    = { "app.kubernetes.io/managed-by" = "Terraform" }
  }

  rule {
    api_groups = ["", "apps"]
    resources  = ["pods", "pods/logs", "deployments", "replicasets", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "readonly" {
  for_each   = toset(local.developer_namespaces)
  depends_on = [kubernetes_role_v1.readonly]

  metadata {
    name      = "readonly-binding"
    namespace = each.key
    labels    = { "app.kubernetes.io/managed-by" = "Terraform" }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "readonly"
  }
  subject {
    kind      = "Group"
    name      = "readonly"
    api_group = "rbac.authorization.k8s.io"
  }
}

module "dguengineer" {
  source = "./modules/access-entry"

  name = "dguengineer"

  cluster_name = local.cluster_name

  access_policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  access_policy_scope      = "namespace"
  access_policy_namespaces = ["datagovuk"]

  namespace_role_rules = [
    {
      api_groups = ["", "apps"],
      resources  = ["pods", "pods/logs", "deployments", "replicasets", "statefulsets"]
      verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    },
    {
      api_groups = ["batch"]
      resources  = ["jobs", "cronjobs"]
      verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    },
    {
      api_groups = [""]
      resources  = ["pods/exec"]
      verbs      = ["create"]
    }
  ]
}
