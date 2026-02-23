locals {
  read_snapshot_bucket_arns = sort(
    distinct(
      concat(
        [module.snapshot_bucket.arn],
        formatlist(
          "arn:aws:s3:::govuk-%s-%s-${local.bucket_suffix}",
          var.read_snapshots_from_environments,
          var.opensearch_domain_name
        ),
      )
    )
  )
  write_snapshot_bucket_arn = module.snapshot_bucket.arn
}

resource "aws_iam_role" "opensearch_snapshot" {
  name               = "govuk-${var.govuk_environment}-${var.opensearch_domain_name}-opensearch-snapshot"
  assume_role_policy = data.aws_iam_policy_document.opensearch_snapshot_assume_role.json
}

data "aws_iam_policy_document" "opensearch_snapshot_assume_role" {
  statement {
    sid = "AllowAWSOpenSearchService"

    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "opensearch_snapshot" {
  statement {
    sid       = "ListSnapshotBuckets"
    actions   = ["s3:ListBucket"]
    resources = local.read_snapshot_bucket_arns
  }

  statement {
    sid       = "ReadSnapshots"
    actions   = ["s3:GetObject"]
    resources = formatlist("%s/*", local.read_snapshot_bucket_arns)
  }

  statement {
    sid = "WriteSnapshots"

    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [local.write_snapshot_bucket_arn]
  }
}

resource "aws_iam_policy" "opensearch_snapshot" {
  name   = "govuk-${var.govuk_environment}-${var.opensearch_domain_name}-opensearch-snapshot"
  policy = data.aws_iam_policy_document.opensearch_snapshot.json
}

resource "aws_iam_policy_attachment" "opensearch_snapshot" {
  name       = "govuk-${var.govuk_environment}-${var.opensearch_domain_name}-opensearch-snapshot"
  roles      = [aws_iam_role.opensearch_snapshot.name]
  policy_arn = aws_iam_policy.opensearch_snapshot.arn
}
