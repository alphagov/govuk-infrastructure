resource "aws_codecommit_repository" "govuk_repos" {
  for_each = data.github_repository.govuk

  repository_name = each.value.name
  description     = each.value.description
  default_branch  = each.value.default_branch

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role" "github_action_mirror_repos_role" {
  name = "github_action_mirror_repos_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${aws_iam_openid_connect_provider.github_provider.arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:sub" : [
              "repo:alphagov/govuk-infrastructure:ref:refs/heads/main"
            ],
            "token.actions.githubusercontent.com:aud" : "${one(aws_iam_openid_connect_provider.github_provider.client_id_list)}"
          },
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_action_mirror_repos_policy" {
  name = "github_action_mirror_repos_policy"
  role = aws_iam_role.github_action_mirror_repos_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "codecommit:GitPull",
          "codecommit:GitPush"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
