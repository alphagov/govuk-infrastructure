resource "aws_s3_bucket" "search_analytics" {
  bucket        = "govuk-search-analytics-${var.govuk_environment}"
  force_destroy = var.force_destroy
  tags = {
    System = "Search"
    Name   = "Search analytics reports for ${var.govuk_environment}"
  }
}

resource "aws_s3_bucket_versioning" "search_analytics" {
  bucket = aws_s3_bucket.search_analytics.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_policy" "search_analytics" {
  bucket = aws_s3_bucket.search_analytics.id
  policy = data.aws_iam_policy_document.search_analytics.json
}

data "aws_iam_policy_document" "search_analytics_github_action_role" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [aws_iam_openid_connect_provider.github_provider.arn]
      type        = "Federated"
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:alphagov/search-analytics:ref:refs/heads/main"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = [one(aws_iam_openid_connect_provider.github_provider.client_id_list)]
    }
  }
}

resource "aws_iam_role" "search_analytics_github_action_role" {
  name               = "search_analytics_github_action_role"
  assume_role_policy = data.aws_iam_policy_document.search_analytics_github_action_role.json
}

# TODO: instead of granting write access to nodes, use IRSA (IAM Roles for
# Service Accounts aka pod identity).
data "aws_iam_policy_document" "search_analytics" {
  statement {
    sid = "EKSNodesCanList"
    principals {
      type        = "AWS"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_arn]
    }
    actions = [
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.search_analytics.arn]
  }
  statement {
    sid = "EKSNodesCanReadAndWrite"
    principals {
      type        = "AWS"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_arn]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.search_analytics.arn}/*"]
  }
  statement {
    sid = "GitHubCanWrite"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.search_analytics_github_action_role.arn]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.search_analytics.arn}/*"]
  }
}


