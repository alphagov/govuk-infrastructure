resource "aws_s3_bucket" "content_data_csvs" {
  bucket = "govuk-${var.govuk_environment}-content-data-csvs"
}

import {
  to = aws_s3_bucket.content_data_csvs
  id = "govuk-${var.govuk_environment}-content-data-csvs"
}

resource "aws_s3_bucket_acl" "content_data_csvs" {
  bucket = aws_s3_bucket.content_data_csvs.id
  acl    = "public-read"
}

resource "aws_s3_bucket_logging" "content_data_csvs" {
  bucket        = aws_s3_bucket.content_data_csvs.id
  target_bucket = "govuk-${var.govuk_environment}-aws-logging"
  target_prefix = "s3/govuk-${var.govuk_environment}-content-data-csvs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "content_data_csvs" {
  bucket = aws_s3_bucket.content_data_csvs.id

  rule {
    id     = "all"
    status = "Enabled"

    expiration {
      days = 7
    }
  }
}
