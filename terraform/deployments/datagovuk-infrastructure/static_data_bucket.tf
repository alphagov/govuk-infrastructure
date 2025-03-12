resource "aws_s3_bucket" "datagovuk_static" {
  bucket = "datagovuk-${var.govuk_environment}-ckan-static-data"
}

resource "aws_s3_bucket_versioning" "datagovuk_static" {
  bucket = aws_s3_bucket.datagovuk_static.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "datagovuk_static" {
  count = startswith(var.govuk_environment, "eph-") ? 0 : 1

  bucket        = aws_s3_bucket.datagovuk_static.id
  target_bucket = "govuk-${var.govuk_environment}-aws-logging"
  target_prefix = "s3/datagovuk-${var.govuk_environment}-ckan-static-data/"
}

data "aws_iam_policy_document" "datagovuk_static" {
  statement {
    sid     = "S3FastlyReadBucket"
    actions = ["s3:GetObject"]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.datagovuk_static.id}",
      "arn:aws:s3:::${aws_s3_bucket.datagovuk_static.id}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"

      values = data.fastly_ip_ranges.fastly.cidr_blocks
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "govuk_datagovuk_static_read_policy" {
  bucket = aws_s3_bucket.datagovuk_static.id
  policy = data.aws_iam_policy_document.datagovuk_static.json
}
