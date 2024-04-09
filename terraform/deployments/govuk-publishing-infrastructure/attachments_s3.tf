resource "aws_s3_bucket" "attachments" {
  bucket = "govuk-attachments-${var.govuk_environment}"
}

resource "aws_s3_bucket_acl" "attachments" {
  bucket = aws_s3_bucket.attachments.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "attachments" {
  count  = var.govuk_environment == "production" ? 1 : 0
  bucket = aws_s3_bucket.attachments.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "attachments" {
  count  = var.govuk_environment == "integration" ? 1 : 0
  bucket = aws_s3_bucket.attachments.id
  rule {
    id = "Expire-30-Days"
    expiration {
      days = 30
    }
    status = "Enabled"
  }
}

import {
  to = aws_s3_bucket.attachments
  id = "govuk-attachments-${var.govuk_environment}"
}
