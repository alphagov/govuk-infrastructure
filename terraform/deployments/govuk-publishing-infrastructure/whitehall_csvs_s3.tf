resource "aws_s3_bucket" "whitehall_csvs" {
  bucket = "govuk-${var.govuk_environment}-whitehall-csvs"
}

resource "aws_s3_bucket_logging" "whitehall_csvs" {
  bucket        = aws_s3_bucket.whitehall_csvs.id
  target_bucket = "govuk-${var.govuk_environment}-aws-logging"
  target_prefix = "s3/govuk-${var.govuk_environment}-whitehall-csvs/"
}

import {
  to = aws_s3_bucket.whitehall_csvs
  id = "govuk-${var.govuk_environment}-whitehall-csvs"
}

import {
  to = aws_s3_bucket_logging.whitehall_csvs
  id = "govuk-${var.govuk_environment}-whitehall-csvs"
}
