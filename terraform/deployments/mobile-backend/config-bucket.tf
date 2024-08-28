resource "aws_s3_bucket" "mobile_backend_remote_config" {
  bucket = "govuk-app-remote-config-${var.govuk_environment}"
}

resource "aws_s3_bucket_versioning" "mobile_backend_remote_config" {
  bucket = aws_s3_bucket.mobile_backend_remote_config.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "mobile_backend_remote_config" {
  bucket        = aws_s3_bucket.mobile_backend_remote_config.id
  target_bucket = "govuk-${var.govuk_environment}-aws-logging"
  target_prefix = "s3/mobile-backend-remote-config-${var.govuk_environment}"
}

data "aws_iam_policy_document" "mobile_backend_remote_config_fastly_read" {
  statement {
    sid     = "S3FastlyReadBucket"
    actions = ["s3:GetObject"]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.mobile_backend_remote_config.id}",
      "arn:aws:s3:::${aws_s3_bucket.mobile_backend_remote_config.id}/*"
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

resource "aws_s3_bucket_policy" "mobile_backend_remote_config_read" {
  bucket = aws_s3_bucket.mobile_backend_remote_config.id
  policy = data.aws_iam_policy_document.mobile_backend_remote_config_fastly_read.json
}
