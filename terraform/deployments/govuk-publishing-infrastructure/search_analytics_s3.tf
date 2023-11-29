resource "aws_s3_bucket" "search_analytics" {
  bucket        = "govuk-search-analytics-${var.govuk_environment}"
  force_destroy = var.force_destroy
  tags = {
    Product     = "GOV.UK"
    System      = "Search analytics"
    Environment = "${var.govuk_environment}"
    Owner       = "govuk-replatforming-team@digital.cabinet-office.gov.uk"

    Name        = "govuk-${var.env}-${var.region}-search-analytics"

    Name        = "Search analytics reports for ${var.govuk_environment}"

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

resource "aws_iam_role" "search_analytics_github_action_role" {
  name = "search_analytics_github_action_role"

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
              "repo:alphagov/search-analytics:ref:refs/heads/main"
            ],
            "token.actions.githubusercontent.com:aud" : "${one(aws_iam_openid_connect_provider.github_provider.client_id_list)}"
          },
        }
      }
    ]
  })
}

# TODO: instead of granting write access to nodes, use IRSA (IAM Roles for
# Service Accounts aka pod identity).
data "aws_iam_policy_document" "search_analytics" {
  statement {
    sid = "EKSNodesCanList"
    principals {
      type        = "AWS"
      identifiers = [data.terraform_remote_state.cluster_infrastructure.outputs.worker_iam_role_arn]
    }
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.search_analytics.arn]
  }
  statement {
    sid = "EKSNodesCanReadAndWrite"
    principals {
      type        = "AWS"
      identifiers = [data.terraform_remote_state.cluster_infrastructure.outputs.worker_iam_role_arn]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
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
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.search_analytics.arn}/*"]
  }
}


