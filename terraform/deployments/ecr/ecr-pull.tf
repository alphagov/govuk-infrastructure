locals {
  ecr_repos = toset([for repo in local.repositories : aws_ecr_repository.github_repositories[repo].name])
}

data "aws_iam_policy_document" "allow_cross_account_pull_from_ecr" {
  for_each = local.ecr_repos

  statement {
    sid    = "AllowCrossAccountPull"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:BatchImportUpstreamImage",
    ]
    principals {
      identifiers = var.puller_arns
      type        = "AWS"
    }
  }

  dynamic "statement" {
    for_each = contains(local.allow_lambda_pull, each.key) ? [each.key] : []

    content {
      sid    = "AllowLambdaToPull"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }

      actions = [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
    }
  }
}

resource "aws_ecr_repository_policy" "pull_from_ecr" {
  for_each   = local.ecr_repos
  repository = each.key
  policy     = data.aws_iam_policy_document.allow_cross_account_pull_from_ecr[each.key].json
}

data "aws_iam_policy_document" "assume_pull_from_ecr_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = var.puller_arns
      type        = "AWS"
    }
  }
}
