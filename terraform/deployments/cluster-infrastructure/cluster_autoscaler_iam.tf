# IAM role and policy to enable the k8s cluster autoscaler to talk to AWS
# APIs to manage autoscaling groups and instances.
#
# The k8s side of the autoscaler is in
# ../cluster-services/cluster_autoscaler.tf.

locals {
  cluster_autoscaler_service_account_namespace = "kube-system"
  cluster_autoscaler_service_account_name      = "cluster-autoscaler"
}

# The rest of this file is taken from
# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/irsa/irsa.tf,
# which is Apache-2.0 licenced:
# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/LICENSE
#
# Significant changes from upstream:
# - The aws_iam_policy uses a constructed name instead of name_prefix.
#
# TODO: If we make any significant changes to this code (i.e. if it diverges
# significantly from upstream), we need to summarise those changes here
# in order to comply with the licence.
module "cluster_autoscaler_iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.3.0"
  create_role                   = true
  role_name                     = "${local.cluster_autoscaler_service_account_name}-${var.cluster_name}"
  role_description              = "Role for Cluster Autoscaler. Corresponds to ${local.cluster_autoscaler_service_account_name} k8s ServiceAccount."
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.cluster_autoscaler_service_account_namespace}:${local.cluster_autoscaler_service_account_name}"]
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "EKSClusterAutoscaler-${var.cluster_name}"
  description = "EKS cluster-autoscaler policy for cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}
