# IAM roles required for manual snapshot process
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

resource "aws_iam_policy" "opensearch_snapshot" {
  name   = "govuk-${var.govuk_environment}-${var.service}-opensearch-snapshot-bucket-policy"
  policy = templatefile(iam_policy.tftpl, { BucketArns = replace(local.snapshot_bucket_arns, "/*", ""), BucketWildArns = local.snapshot_bucket_arns })
}

resource "aws_iam_policy_attachment" "opensearch_snapshot" {
  name       = "govuk-${var.govuk_environment}-${var.service}-opensearch-snapshot-bucket-policy-attachment"
  roles      = [aws_iam_role.opensearch_snapshot.name]
  policy_arn = aws_iam_policy.opensearch_snapshot.arn
}
