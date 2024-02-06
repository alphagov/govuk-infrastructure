data "aws_iam_policy_document" "allow_cross_account_pull_from_ecr" {
  statement {
    sid    = "AllowCrossAccountPull"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage"
    ]
    principals {
      identifiers = var.puller_arns
      type        = "AWS"
    }
  }
}

resource "aws_ecr_repository_policy" "pull_from_ecr" {
  for_each   = toset([for repo in local.repositories : aws_ecr_repository.repositories[repo].name])
  repository = each.key
  policy     = data.aws_iam_policy_document.allow_cross_account_pull_from_ecr.json
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

resource "aws_iam_role" "pull_from_ecr" {
  name               = "pull_from_ecr"
  assume_role_policy = data.aws_iam_policy_document.assume_pull_from_ecr_role.json
}

data "aws_iam_policy_document" "pull_from_ecr" {
  statement {
    sid    = "AllowECRPull"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:List*",
      "ecr:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowECRToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "pull_from_ecr" {
  name   = "pull_from_ecr"
  policy = data.aws_iam_policy_document.pull_from_ecr.json
}

resource "aws_iam_role_policy_attachment" "pull_from_ecr" {
  role       = aws_iam_role.pull_from_ecr.name
  policy_arn = aws_iam_policy.pull_from_ecr.arn
}
