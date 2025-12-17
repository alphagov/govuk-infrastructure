# Bucket to store data from Kinesis Firehose, stores both successes and errors
resource "aws_s3_bucket" "csp_reports" {
  bucket = "govuk-${var.govuk_environment}-csp-reports"

  tags = {
    Name = "govuk-${var.govuk_environment}-csp-reports"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "csp_reports_lifecycle" {
  bucket = aws_s3_bucket.csp_reports.id

  rule {
    id     = "govuk-${var.govuk_environment}-csp-reports-lifecycle"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_policy" "csp_reports" {
  bucket = aws_s3_bucket.csp_reports.id
  policy = data.aws_iam_policy_document.csp_reports_bucket_policy.json
}

data "aws_iam_policy_document" "csp_reports_bucket_policy" {
  statement {
    sid    = "DenyNonTLS"
    effect = "Deny"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.csp_reports.arn}/*"]
    condition {
      test     = "Bool"
      values   = [false]
      variable = "aws:SecureTransport"
    }
  }
}
