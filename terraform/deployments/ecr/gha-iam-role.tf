locals {
  github_oidc_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

data "aws_iam_openid_connect_provider" "github_oidc" {
  arn = local.github_oidc_arn
}

data "aws_iam_policy_document" "ecr_role_permissions" {
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeImages",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:GetAuthorizationToken",
      "ecr:CompleteLayerUpload"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "kms:DescribeKey",
      "kms:GetPublicKey",
      "kms:Sign"
    ]
    resources = [aws_kms_key.container_signing_key.arn]
  }
}

data "aws_iam_policy_document" "ecr_role_trust" {
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
      values   = [for repo in local.repositories : "repo:alphagov/${repo}"]
    }
  }
}

resource "aws_iam_role" "ecr_role" {
  name                 = "github_action_ecr_push"
  max_session_duration = 10800
  assume_role_policy   = data.aws_iam_policy_document.ecr_role_trust.json
}

resource "aws_iam_role_policy" "ecr_role" {
  name   = "github_action_ecr_push_policy"
  role   = aws_iam_role.ecr_role.id
  policy = data.aws_iam_policy_document.ecr_role_permissions.json
}
