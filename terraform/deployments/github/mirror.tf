resource "aws_codecommit_repository" "govuk_repos" {
  for_each = data.github_repository.govuk

  repository_name = each.value.name
  description     = each.value.description
  default_branch  = each.value.default_branch
}

data "aws_iam_policy_document" "github_action_can_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:alphagov/govuk-infrastructure:ref:refs/heads/main"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = aws_iam_openid_connect_provider.github_provider.client_id_list
    }
  }
}

resource "aws_iam_role" "github_action_mirror_repos_role" {
  name                 = "github_action_mirror_repos_role"
  max_session_duration = 10800
  assume_role_policy   = data.aws_iam_policy_document.github_action_can_assume_role.json
}

data "aws_iam_policy_document" "push_to_codecommit" {
  statement {
    actions   = ["codecommit:GitPush"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_action_mirror_repos_policy" {
  name   = "github_action_mirror_repos_policy"
  role   = aws_iam_role.github_action_mirror_repos_role.id
  policy = data.aws_iam_policy_document.push_to_codecommit.json
}
