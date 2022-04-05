# IAM role and policy to allow Filebeat to access Cloudwatch Logs for the cluster-level k8s logs
#
# k8s side is in ../cluster-services/cluster_logging.tf

locals {
  cluster_logging_service_account_namespace = "kube-system"
  cluster_logging_service_account_name      = "cluster-logging"
}

module "cluster_logging_iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.3.0"
  create_role                   = true
  role_name                     = "${local.cluster_autoscaler_service_account_name}-${var.cluster_name}"
  role_description              = "Role for cluster-level log reading. Corresponds to ${local.cluster_autoscaler_service_account_name} k8s ServiceAccount."
  provider_url                  = local.cluster_oidc_issuer
  role_policy_arns              = [aws_iam_policy.cluster_logging.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.cluster_logging_service_account_namespace}:${local.cluster_logging_service_account_name}"]
}

resource "aws_iam_policy" "cluster_logging" {
  name        = "EKSClusterLogging-${var.cluster_name}"
  description = "Policy for cluster-level log reading for cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.cluster_logging.json
}

data "aws_iam_policy_document" "cluster_logging" {
  statement {
    sid = "clusterLoggingAllowRead"

    effect = "Allow"

    actions = [
      "logs:DescribeLogGroups",
      "logs:FilterLogEvents"
    ]

    resources = [
      "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/eks/govuk/cluster"
    ]
  }
}
