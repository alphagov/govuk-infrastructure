resource "aws_s3_bucket" "govuk_ai_accelerator_data" {
  bucket = "govuk-ai-accelerator-data-integration"
  count  = var.govuk_environment == "integration" ? 1 : 0
}

resource "aws_s3_bucket_public_access_block" "govuk_ai_accelerator_data_access_block" {
  bucket = aws_s3_bucket.govuk_ai_accelerator_data[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  count = var.govuk_environment == "integration" ? 1 : 0
}

resource "aws_s3_bucket_versioning" "govuk_ai_accelerator_data_versioning" {
  bucket = aws_s3_bucket.govuk_ai_accelerator_data[0].id

  versioning_configuration {
    status = "Enabled"
  }

  count = var.govuk_environment == "integration" ? 1 : 0
}

resource "aws_s3_bucket_server_side_encryption_configuration" "govuk_ai_accelerator_data_encryption" {
  bucket = aws_s3_bucket.govuk_ai_accelerator_data[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  count = var.govuk_environment == "integration" ? 1 : 0
}

data "aws_iam_policy_document" "https_only" {
  count = var.govuk_environment == "integration" ? 1 : 0
  
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    sid     = "https_only"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.govuk_ai_accelerator_data[0].arn,
      "${aws_s3_bucket.govuk_ai_accelerator_data[0].arn}/*"
    ]
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}

resource "aws_s3_bucket_policy" "govuk_ai_accelerator_data_bucket_policy" {
  bucket = aws_s3_bucket.govuk_ai_accelerator_data[0].id
  policy = data.aws_iam_policy_document.https_only.json

  count = var.govuk_environment == "integration" ? 1 : 0
}

resource "aws_s3_bucket_ownership_controls" "govuk_ai_accelerator_data_owner_controls" {
  bucket = aws_s3_bucket.govuk_ai_accelerator_data[0].id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  count = var.govuk_environment == "integration" ? 1 : 0
}

resource "aws_s3_bucket_logging" "govuk_ai_accelerator_data_logging" {
  bucket        = aws_s3_bucket.govuk_ai_accelerator_data[0].id
  target_bucket = "govuk-integration-aws-logging"
  target_prefix = "s3/govuk-ai-accelerator-data-integration/"

  count = var.govuk_environment == "integration" ? 1 : 0
}
