locals {
  external_secrets_service_account_name = "external-secrets" # pragma: allowlist secret
  external_secrets_ns                   = "cluster-services"
  secrets_prefix                        = var.environment_name # pragma: allowlist secret
}

module "external_secrets_iam_role" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "~> 6.0"
  name               = "${var.environment_name}-${local.external_secrets_service_account_name}"
  use_name_prefix    = false
  description        = "Role for External Secrets addon. Corresponds to ${local.external_secrets_service_account_name} k8s ServiceAccount."
  enable_oidc        = true
  oidc_provider_urls = [data.tfe_outputs.cluster_init.nonsensitive_values.oidc_provider]
  policies = {
    "${aws_iam_policy.external_secrets.name}" = aws_iam_policy.external_secrets.arn
  }
  oidc_subjects = ["system:serviceaccount:${local.external_secrets_ns}:${local.external_secrets_service_account_name}"]
}


resource "aws_iam_policy" "external_secrets" {
  name        = "${var.environment_name}-EKSExternalSecrets"
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

