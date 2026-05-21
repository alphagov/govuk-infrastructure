data "aws_iam_policy_document" "s3_fastly_read_policy_doc_ckan_output" {
  statement {
    sid     = "S3FastlyReadBucket"
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.ckan-output.id}",
      "arn:aws:s3:::${aws_s3_bucket.ckan-output.id}/*",
    ]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = data.fastly_ip_ranges.fastly.cidr_blocks
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket" "ckan-output" {
  bucket = "datagovuk-${var.govuk_environment}-ckan-output"
  tags   = { Name = "datagovuk-${var.govuk_environment}-ckan-output" }
}

resource "aws_s3_bucket_versioning" "ckan_output" {

  bucket = aws_s3_bucket.ckan-output.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_logging" "ckan_output" {
  count = startswith(var.govuk_environment, "eph-") ? 0 : 1

  bucket        = aws_s3_bucket.ckan-output.id
  target_bucket = "govuk-${var.govuk_environment}-aws-logging"
  target_prefix = "s3/datagovuk-${var.govuk_environment}-ckan-output/"
}

resource "aws_s3_bucket_cors_configuration" "ckan_output" {
  bucket = aws_s3_bucket.ckan-output.id
  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = var.output_bucket_cors_origins
  }
}

resource "aws_s3_bucket_policy" "govuk_ckan_output_read_policy" {
  bucket = aws_s3_bucket.ckan-output.id
  policy = data.aws_iam_policy_document.s3_fastly_read_policy_doc.json
}

resource "aws_s3_bucket_public_access_block" "ckan_output" {
  bucket = aws_s3_bucket.ckan-output.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "ckan_output" {
  bucket = aws_s3_bucket.ckan-output.id

  rule {
    object_ownership = "ObjectWriter"
  }
}
