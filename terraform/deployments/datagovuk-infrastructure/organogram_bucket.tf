data "aws_iam_policy_document" "s3_fastly_read_policy_doc" {
  statement {
    sid     = "S3FastlyReadBucket"
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.datagovuk-organogram.id}",
      "arn:aws:s3:::${aws_s3_bucket.datagovuk-organogram.id}/*",
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

resource "aws_s3_bucket" "datagovuk-organogram" {
  bucket = "datagovuk-${var.govuk_environment}-ckan-organogram"
  tags   = { Name = "datagovuk-${var.govuk_environment}-ckan-organogram" }
}

resource "aws_s3_bucket_versioning" "datagovuk_organogram" {

  bucket = aws_s3_bucket.datagovuk-organogram.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_logging" "datagovuk_organogram" {
  count = startswith(var.govuk_environment, "eph-") ? 0 : 1

  bucket        = aws_s3_bucket.datagovuk-organogram.id
  target_bucket = "govuk-${var.govuk_environment}-aws-logging"
  target_prefix = "s3/datagovuk-${var.govuk_environment}-ckan-organogram/"
}

resource "aws_s3_bucket_cors_configuration" "datagovuk_organogram" {
  bucket = aws_s3_bucket.datagovuk-organogram.id
  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = var.organogram_bucket_cors_origins
  }
}

resource "aws_s3_bucket_policy" "govuk_datagovuk_organogram_read_policy" {
  bucket = aws_s3_bucket.datagovuk-organogram.id
  policy = data.aws_iam_policy_document.s3_fastly_read_policy_doc.json
}

resource "aws_s3_bucket_public_access_block" "datagovuk_organogram" {
  bucket = aws_s3_bucket.datagovuk-organogram.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "datagovuk_organogram" {
  bucket = aws_s3_bucket.datagovuk-organogram.id

  rule {
    object_ownership = "ObjectWriter"
  }
}
