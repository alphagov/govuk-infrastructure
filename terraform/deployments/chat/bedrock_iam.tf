resource "aws_iam_role" "bedrock_access" {
  name                 = "govuk-chat-bedrock-access-role"
  assume_role_policy   = data.aws_iam_policy_document.bedrock_access_assume_role.json
  max_session_duration = 28800
}

data "aws_iam_policy_document" "bedrock_access_assume_role" {
  statement {
    principals {
      type        = "Federated"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn, "/^(.*provider/)/", "")}:sub"
      values   = ["system:serviceaccount:apps:govuk-chat"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn, "/^(.*provider/)/", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "bedrock_access" {
  statement {
    sid = "BedrockAssumeRolePolicy"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "bedrock_access" {
  name   = "govuk-chat-bedrock-access-policy"
  policy = data.aws_iam_policy_document.bedrock_access.json
}

resource "aws_iam_role_policy_attachment" "bedrock_access" {
  role       = aws_iam_role.bedrock_access.name
  policy_arn = aws_iam_policy.bedrock_access.arn
}
