data "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "config_signing_role_permissions" {
  statement {
    actions = [
      "kms:DescribeKey",
      "kms:GetPublicKey",
      "kms:Sign"
    ]
    resources = [aws_kms_key.config_signing_key.arn]
  }
}

data "aws_iam_policy_document" "config_signing_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github_oidc.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = data.aws_iam_openid_connect_provider.github_oidc.client_id_list
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:alphagov/govuk-mobile-backend-config:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "config_signing" {
  name                 = "github_action_config_signing"
  max_session_duration = 10800
  assume_role_policy   = data.aws_iam_policy_document.config_signing_trust.json
}

resource "aws_iam_role_policy" "config_signing" {
  name   = "github_action_config_signing_policy"
  role   = aws_iam_role.config_signing.id
  policy = data.aws_iam_policy_document.config_signing_role_permissions.json
}
