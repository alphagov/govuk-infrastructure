locals {
  github_oidc_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

data "aws_iam_openid_connect_provider" "github_oidc" {
  arn = local.github_oidc_arn
}

data "aws_iam_policy_document" "gha_image_attestation_role_permissions" {
  statement {
    actions = [
      "kms:DescribeKey",
      "kms:GetPublicKey",
      "kms:Sign"
    ]
    resources = [aws_kms_key.container_signing_key.arn]
  }
}

data "aws_iam_policy_document" "gha_image_attestation_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = data.aws_iam_openid_connect_provider.github_oidc.client_id_list
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:alphagov/govuk-ruby-images"]
    }
  }
}

resource "aws_iam_role" "gha_image_attestation" {
  name                 = "github_action_image_attestation"
  max_session_duration = 10800
  assume_role_policy   = data.aws_iam_policy_document.gha_image_attestation_trust.json
}

resource "aws_iam_role_policy" "gha_image_attestation" {
  name   = "github_action_image_attestation_policy"
  role   = aws_iam_role.gha_image_attestation.id
  policy = data.aws_iam_policy_document.gha_image_attestation_role_permissions.json
}
