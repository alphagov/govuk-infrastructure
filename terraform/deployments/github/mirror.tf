locals {
  codecommit_repos = {
    for name, repo in local.repo_metadata :
    "alphagov/${name}" => {
      repo_name   = name
      description = try(repo.description, "Mirror of GitHub repository alphagov/${name}")
    }
    if contains(data.github_repositories.govuk.full_names, format("alphagov/%s", name))
  }
}

resource "aws_codecommit_repository" "govuk_repos" {
  for_each = local.codecommit_repos

  repository_name = each.value.repo_name
  # description     = each.value.description
  default_branch = "main"

  lifecycle {
    ignore_changes = [
      description
    ]
  }
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
