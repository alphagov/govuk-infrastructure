locals {
  github_subjects = [
    "repo:${var.github_repository}:ref:refs/heads/*",
    "repo:${var.github_repository}:pull_request",
  ]

  bedrock_model_arns = [for id in var.bedrock_model_ids : "arn:aws:bedrock:${var.aws_region}::foundation-model/${id}"]
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid     = "GitHubActionsAssumeRoleWithWebIdentity"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_subjects
    }
  }
}

resource "aws_iam_role" "github_actions_bedrock_ci" {
  name                 = var.role_name
  assume_role_policy   = data.aws_iam_policy_document.github_actions_assume_role.json
  max_session_duration = 3600
}

data "aws_iam_policy_document" "bedrock_invoke_policy" {
  statement {
    sid    = "InvokeBedrock"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
    ]
    resources = local.bedrock_model_arns
  }

  statement {
    sid       = "ListFoundationModels"
    effect    = "Allow"
    actions   = ["bedrock:ListFoundationModels"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "bedrock_invoke_policy" {
  name        = "${var.role_name}-policy"
  description = "Allow GitHub Actions CI to invoke specified Bedrock models in ${var.aws_region}"
  policy      = data.aws_iam_policy_document.bedrock_invoke_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_bedrock_invoke" {
  role       = aws_iam_role.github_actions_bedrock_ci.name
  policy_arn = aws_iam_policy.bedrock_invoke_policy.arn
}
