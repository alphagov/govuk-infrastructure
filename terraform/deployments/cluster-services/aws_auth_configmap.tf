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

locals {
  default_configmap_roles = [
    {
      rolearn  = data.terraform_remote_state.cluster_infrastructure.outputs.worker_iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
  ]

  admin_roles_and_arns = data.terraform_remote_state.infra_security.outputs.admin_roles_and_arns
  admin_configmap_roles = [
    for user, arn in local.admin_roles_and_arns : {
      rolearn  = arn
      username = user
      groups   = ["cluster-admins"]
    }
  ]

  ci_planner_username_and_rolearn = {
    "govuk-ci-concourse" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/govuk-ci-concourse"
  }

  readonly_roles_and_arns = merge(data.terraform_remote_state.infra_security.outputs.user_roles_and_arns, local.ci_planner_username_and_rolearn)
  readonly_configmap_roles = [
    for user, arn in local.readonly_roles_and_arns : {
      rolearn  = arn
      username = user
      groups   = ["readonly"]
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
    mapRoles = yamlencode(
      distinct(concat(
        local.default_configmap_roles,
        local.admin_configmap_roles,
        local.readonly_configmap_roles,
      ))
    )
  }
}

resource "kubernetes_cluster_role_binding" "cluster_admins" {
  metadata {
    name = "cluster-admins"
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

resource "kubernetes_cluster_role_binding" "cluster_readonly" {
  metadata {
    name = "cluster-readonly"
  }
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
  metadata {
    name = "read-crs-and-crbs"
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["clusterrolebindings", "clusterroles"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "read_crs_and_crbs" {
  metadata {
    name = "read-crs-and-crbs"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.read_crs_and_crbs.metadata.0.name
  }
  subject {
    kind      = "Group"
    name      = "readonly"
    api_group = "rbac.authorization.k8s.io"
  }
}
