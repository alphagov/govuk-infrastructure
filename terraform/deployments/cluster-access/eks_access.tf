locals {
  developer_namespaces = ["apps", "licensify"]
}

module "platformengineer" {
  source = "./modules/access-entry"

  name = "platformengineer"

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
