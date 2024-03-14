data "fastly_ip_ranges" "fastly" {}

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
  bucket        = aws_s3_bucket.datagovuk-organogram.id
  target_bucket = data.terraform_remote_state.infra_monitoring.outputs.aws_logging_bucket_id
  target_prefix = "s3/datagovuk-${var.govuk_environment}-ckan-organogram/"
}

resource "aws_s3_bucket_cors_configuration" "datagovuk_organogram" {
  bucket = aws_s3_bucket.datagovuk-organogram.id
  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = [
      "https://data.gov.uk",
      "https://staging.data.gov.uk",
      "https://www.staging.data.gov.uk",
      "https://integration.data.gov.uk",
      "https://www.integration.data.gov.uk",
      "https://find.eks.production.govuk.digital",
      "https://find.eks.integration.govuk.digital",
      "https://find.eks.staging.govuk.digital"
    ]
  }
}

resource "aws_s3_bucket_policy" "govuk_datagovuk_organogram_read_policy" {
  bucket = aws_s3_bucket.datagovuk-organogram.id
  policy = data.aws_iam_policy_document.s3_fastly_read_policy_doc.json
}
