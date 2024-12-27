# IAM role and policy to enable the k8s external-secrets operator to talk to
# AWS APIs to access and manage SecretsManager secrets.
#
# The k8s side of the external-secrets operator is in
# ../cluster-services/external_secrets.tf.

locals {
  external_secrets_service_account_name = "external-secrets"
}

module "external_secrets_iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 5.0"
  create_role                   = true
  role_name                     = "${local.external_secrets_service_account_name}-${var.cluster_name}"
  role_description              = "Role for External Secrets addon. Corresponds to ${local.external_secrets_service_account_name} k8s ServiceAccount."
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.external_secrets.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.cluster_services_namespace}:${local.external_secrets_service_account_name}"]
}

resource "aws_iam_policy" "external_secrets" {
  name        = "EKSExternalSecrets-${var.cluster_name}"
  description = "EKS ${local.external_secrets_service_account_name} policy for cluster ${module.eks.cluster_name}"
  policy      = data.aws_iam_policy_document.external_secrets.json
}

# Policy as documented here:
# https://external-secrets.io/provider-aws-secrets-manager/#iam-policy
data "aws_iam_policy_document" "external_secrets" {
  statement {
    sid    = "externalSecretsSecretsManager"
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:BatchGetSecretValue"
    ]

    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${local.secrets_prefix}/*",
    ]
  }
}
