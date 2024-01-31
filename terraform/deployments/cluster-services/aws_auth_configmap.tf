# Generate the aws-auth ConfigMap, which defines the mapping between AWS IAM
# roles and k8s RBAC. The authoritative ACLs are defined in
# https://github.com/alphagov/govuk-aws-data/blob/master/data/infra-security/
# and read here via Terraform remote state.
#
# The aws-auth ConfigMap is documented at
# https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html
#
# Generally, it is unwise to manage k8s objects directly from Terraform (as
# opposed to using Helm or kubectl or other tooling designed to work with
# k8s). This is a rare exception to that rule of thumb.

data "aws_iam_roles" "admin" { name_regex = "(^terraform-cloud$|\\..*-admin$)" }
data "aws_iam_roles" "poweruser" { name_regex = "\\..*-poweruser$" }
data "aws_iam_roles" "user" { name_regex = "\\..*-user$" }
data "aws_iam_roles" "licensinguser" { name_regex = "\\..*-licensinguser$" }

locals {
  default_configmap_roles = [
    {
      rolearn  = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
  ]

  admin_configmap_roles = [
    for arn in data.aws_iam_roles.admin.arns : {
      rolearn  = arn
      username = regex("/(terraform-cloud|.*-admin)$", arn)[0]
      groups   = ["cluster-admins"]
    }
  ]

  poweruser_configmap_roles = [
    for arn in data.aws_iam_roles.poweruser.arns : {
      rolearn  = arn
      username = regex("/(.*-poweruser)$", arn)[0]
      groups   = ["powerusers"]
    }
  ]

  readonly_configmap_roles = [
    for arn in data.aws_iam_roles.user.arns : {
      rolearn  = arn
      username = regex("/(.*-user)$", arn)[0]
      groups   = ["readonly"]
    }
  ]

  licensing_configmap_roles = [
    for arn in data.aws_iam_roles.licensinguser.arns : {
      rolearn  = arn
      username = regex("/(.*-licensinguser)$", arn)[0]
      groups   = ["licensing"]
    }
  ]
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
    labels    = { "app.kubernetes.io/managed-by" = "Terraform" }
  }
  data = {
    mapRoles = yamlencode(distinct(concat(
      local.default_configmap_roles,
      local.admin_configmap_roles,
      local.readonly_configmap_roles,
      local.poweruser_configmap_roles,
      local.licensing_configmap_roles,
    )))
  }
}

import {
  to = kubernetes_config_map.aws_auth
  id = "kube-system/aws-auth"
}

resource "kubernetes_cluster_role_binding" "cluster_admins" {
  metadata { name = "cluster-admins" }
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

resource "kubernetes_cluster_role_binding" "cluster_readonly" {
  metadata { name = "cluster-readonly" }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind      = "Group"
    name      = "readonly"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role" "read_crs_and_crbs" {
  metadata { name = "read-crs-and-crbs" }
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["clusterrolebindings", "clusterroles"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "read_crs_and_crbs" {
  metadata { name = "read-crs-and-crbs" }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.read_crs_and_crbs.metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "readonly"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role" "poweruser" {
  metadata { name = "poweruser" }
  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "poweruser" {
  for_each = toset([kubernetes_namespace.apps.metadata[0].name, "datagovuk"])

  metadata {
    name      = "poweruser-${each.key}"
    namespace = each.key
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

resource "kubernetes_role" "licensing" {
  metadata {
    name      = "licensing"
    namespace = "licensify"
  }

  rule {
    api_groups = ["", "apps"]
    resources  = ["pods", "pods/log", "deployments", "replicasets", "events"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create"]
  }
}

resource "kubernetes_role_binding" "licensing" {
  metadata {
    name      = "licensing"
    namespace = "licensify"
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
