locals {
  default_configmap_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.eks_workers.name}"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
  ]

  hydrated_admin_roles = [for role in var.admin_roles :
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${role}"
      username = "admin"
      groups   = ["system:masters"]
    }
  ]
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
    labels = merge(
      {
        "app.kubernetes.io/managed-by" = "Terraform"
      },
    )
  }

  data = {
    mapRoles = yamlencode(
      distinct(concat(
        local.default_configmap_roles,
        local.hydrated_admin_roles,
      ))
    )
  }

  depends_on = [aws_eks_cluster.govuk]
}
