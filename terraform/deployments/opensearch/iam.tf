# IAM roles required for manual snapshot process
locals {
  snapshot_bucket_arns = {
    production = ["arn:aws:s3:::govuk-production-chat-opensearch-snapshots"]
    staging = [
      "arn:aws:s3:::govuk-production-chat-opensearch-snapshots",
      "arn:aws:s3:::govuk-staging-chat-opensearch-snapshots",
    ]
    integration = [
      "arn:aws:s3:::govuk-production-chat-opensearch-snapshots",
      "arn:aws:s3:::govuk-integration-chat-opensearch-snapshots",
    ]
  }[var.govuk_environment]
}

resource "aws_iam_role" "opensearch_snapshot" {
  name               = "govuk-${var.govuk_environment}-${var.service}-opensearch-snapshot-role"
  assume_role_policy = data.aws_iam_policy_document.opensearch_snapshot_assume_role.json
}

data "aws_iam_policy_document" "opensearch_snapshot_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "opensearch_snapshot" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = local.snapshot_bucket_arns
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = formatlist("%s/*", local.snapshot_bucket_arns)
  }
}

resource "aws_iam_policy" "opensearch_snapshot" {
  name   = "govuk-${var.govuk_environment}-${var.service}-opensearch-snapshot-bucket-policy"
  policy = data.aws_iam_policy_document.opensearch_snapshot.json
}

resource "aws_iam_policy_attachment" "opensearch_snapshot" {
  name       = "govuk-${var.govuk_environment}-${var.service}-opensearch-snapshot-bucket-policy-attachment"
  roles      = [aws_iam_role.opensearch_snapshot.name]
  policy_arn = aws_iam_policy.opensearch_snapshot.arn
}
