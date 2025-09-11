# IAM role and policy to enable the k8s external-secrets operator to talk to
# AWS APIs to access and manage SecretsManager secrets.
#
# The k8s side of the external-secrets operator is in
# ../cluster-services/external_secrets.tf.

locals {
  external_secrets_service_account_name = "external-secrets" # pragma: allowlist secret
}

module "external_secrets_iam_role" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "~> 6.0"
  name               = "${local.external_secrets_service_account_name}-${var.cluster_name}"
  use_name_prefix    = false
  description        = "Role for External Secrets addon. Corresponds to ${local.external_secrets_service_account_name} k8s ServiceAccount."
  enable_oidc        = true
  oidc_provider_urls = [module.eks.oidc_provider]
  policies = {
    "${aws_iam_policy.external_secrets.name}" = aws_iam_policy.external_secrets.arn
  }
  oidc_subjects = ["system:serviceaccount:${local.cluster_services_namespace}:${local.external_secrets_service_account_name}"]
}

moved {
  from = module.external_secrets_iam_role.aws_iam_role_policy_attachment.custom[0]
  to   = module.external_secrets_iam_role.aws_iam_role_policy_attachment.this["EKSExternalSecrets-govuk"]
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
      "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:${local.secrets_prefix}/*",
    ]
  }
}
