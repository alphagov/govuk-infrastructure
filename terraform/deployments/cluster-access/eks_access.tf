
data "aws_iam_roles" "cluster-admin" { name_regex = "\\..*-platformengineer$" }

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

module "fulladmin" {
  source = "./modules/access-entry"

  name = "fulladmin"

  cluster_name = local.cluster_name

  access_policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_policy_scope = "cluster"

  cluster_role_rules = [
    {
      api_groups = ["*"]
      resources  = ["*"]
      verbs      = ["*"]
    }
  ]
}

module "developer" {
  source = "./modules/access-entry"

  name = "developer"

  cluster_name = local.cluster_name

  access_policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  access_policy_scope      = "namespace"
  access_policy_namespaces = local.developer_namespaces

  cluster_role_rules = [
    {
      api_groups = [""]
      resources  = ["namespaces", "pods", "pods/logs", "services", "configmaps", "secrets", "endpoints", "events"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups = ["apps", "batch"]
      resources  = ["deployments", "replicasets", "statefulsets", "jobs", "cronjobs"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups = ["networking.k8s.io"]
      resources  = ["ingresses"]
      verbs      = ["get", "list", "watch"]
    }
  ]

  namespace_role_rules = [
    {
      api_groups = ["", "apps"]
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

module "licensinguser" {
  source = "./modules/access-entry"

  name = "licensinguser"

  cluster_name = local.cluster_name

  access_policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  access_policy_scope      = "namespace"
  access_policy_namespaces = ["licensify"]

  namespace_role_rules = [
    {
      api_groups = ["", "apps"]
      resources  = ["pods", "pods/logs", "deployments", "replicasets", "statefulsets"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups = ["batch"]
      resources  = ["jobs", "cronjobs"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups = [""]
      resources  = ["pods/exec"]
      verbs      = ["create"]
    }
  ]
}

module "ithctester" {
  source = "./modules/access-entry"

  name = "ithctester"

  cluster_name = local.cluster_name

  access_policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  access_policy_scope = "cluster"

  cluster_role_rules = [
    {
      api_groups = ["argoproj.io", "external-secrets.io"]
      resources  = ["*"]
      verbs      = ["get", "list", "watch"]
    }
  ]
}

module "readonly" {
  source = "./modules/access-entry"

  name = "readonly"

  cluster_name = local.cluster_name

  access_policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  access_policy_scope      = "namespace"
  access_policy_namespaces = local.developer_namespaces

  cluster_role_rules = [
    {
      api_groups = [""]
      resources  = ["namespaces", "pods", "pods/logs", "services", "configmaps", "endpoints", "events"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups = [""]
      resources  = ["secrets"]
      verbs      = ["list"]
    },
    {
      api_groups = ["apps", "batch"]
      resources  = ["deployments", "replicasets", "statefulsets", "jobs", "cronjobs"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups = ["networking.k8s.io"]
      resources  = ["ingresses"]
      verbs      = ["get", "list", "watch"]
    }
  ]
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
