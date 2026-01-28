locals {
  renovate_service_account_name = "renovate-irsa"
}

module "renovate_irsa" {
  count = (var.govuk_environment == "production" ? 1 : 0)

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 6.0"

  role_name            = "${local.renovate_service_account_name}-${data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id}"
  role_description     = "AWS Role and EKS service account that allows renovate to query the AWS API through the AWS SDK for EKS the latest EKS addon versions"
  max_session_duration = 7200

  role_policy_arns = { policy = aws_iam_policy.renovate_eks_describe_addons[0].arn }
  oidc_providers = {
    main = {
      provider_arn               = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn
      namespace_service_accounts = ["cluster-services:${local.renovate_service_account_name}"]
    }
  }
}

data "aws_iam_policy_document" "renovate_eks_describe_addons" {
  statement {
    sid    = "AllowDescribeEKSAddonVersions"
    effect = "Allow"
    actions = [
      "eks:DescribeAddonVersions"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "renovate_eks_describe_addons" {
  count       = (var.govuk_environment == "production" ? 1 : 0)
  name        = "renovate_eks_describe_addons"
  description = "Permissions to allow renovate to describe eks addons"
  policy      = data.aws_iam_policy_document.renovate_eks_describe_addons.json
}

