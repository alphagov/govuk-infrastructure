data "aws_caller_identity" "current" {}

locals {
  # production can assume everywhere,
  # other accounts can assume into themselves
  account_ids = var.govuk_environment == "production" ? [
    "172025368201", # production
    "696911096973", # staging
    "210287912431", # integration
    "430354129336"  # test
  ] : [data.aws_caller_identity.current.account_id]

  assume_arns = [
    for id in local.account_ids : "arn:aws:iam::${id}:role/synthetic-test-assumed"
  ]
}

data "aws_iam_policy_document" "synthetic_test_assumer_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn, "/^(.*provider/)/", "")}:sub"
      values   = ["system:serviceaccount:apps:synthetic-test-assumer"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn, "/^(.*provider/)/", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "synthetic_test_assumer" {
  name               = "synthetic-test-assumer"
  assume_role_policy = data.aws_iam_policy_document.synthetic_test_assumer_assume.json
}

data "aws_iam_policy_document" "synthetic_test_assumer" {
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = local.assume_arns
  }
}

resource "aws_iam_policy" "synthetic_test_assumer" {
  name        = "synthetic-test-assumer"
  description = "Allow Synthetic Test app to assume roles in each environment"

  policy = data.aws_iam_policy_document.synthetic_test_assumer.json
}

resource "aws_iam_role_policy_attachment" "synthetic_test_assumer" {
  role       = aws_iam_role.synthetic_test_assumer.name
  policy_arn = aws_iam_policy.synthetic_test_assumer.arn
}