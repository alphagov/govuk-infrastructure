# S3 bucket configuration for manual snapshot process
resource "aws_s3_bucket" "opensearch_snapshot" {
  bucket = "govuk-${var.govuk_environment}-${var.service}-opensearch-snapshots"
  tags   = { Name = "govuk-${var.govuk_environment}-${var.service}-opensearch-snapshots" }
}

resource "aws_s3_bucket_public_access_block" "opensearch_snapshot" {
  bucket                  = aws_s3_bucket.opensearch_snapshot.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "opensearch_snapshot" {
  bucket        = aws_s3_bucket.opensearch_snapshot.id
  target_bucket = "govuk-${var.govuk_environment}-aws-logging"
  target_prefix = "s3/govuk-${var.govuk_environment}-${var.service}-opensearch-snapshots/"
}

resource "aws_s3_bucket_versioning" "opensearch_snapshot" {
  bucket = aws_s3_bucket.opensearch_snapshot.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "opensearch_snapshot" {
  bucket = aws_s3_bucket.opensearch_snapshot.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "opensearch_snapshot" {
  bucket = aws_s3_bucket.opensearch_snapshot.id
  rule {
    id     = "production"
    status = var.govuk_environment == "production" ? "Enabled" : "Disabled"
    filter {}
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
    expiration { days = 120 }
    noncurrent_version_expiration { noncurrent_days = 1 }
  }
  rule {
    id     = "non-production"
    status = var.govuk_environment != "production" ? "Enabled" : "Disabled"
    filter {}
    expiration { days = 2 }
    noncurrent_version_expiration { noncurrent_days = 1 }
  }
}

resource "aws_s3_bucket_policy" "opensearch_snapshot" {
  bucket = aws_s3_bucket.opensearch_snapshot.id
  policy = data.aws_iam_policy_document.opensearch_snapshot_bucket_policy.json
}

data "aws_iam_policy_document" "opensearch_snapshot_bucket_policy" {
  statement {
    sid = "CrossAccountAccess"
    principals {
      type = "AWS"
      identifiers = [
        "172025368201", # Production
        "696911096973", # Staging
        "210287912431", # Integration
      ]
    }
    # This bucket is only for copying the indices from prod to
    # staging/integration. Backup snapshot of prod are stored separately, so
    # the (required) put/delete permissions here don't represent a problem.
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      aws_s3_bucket.opensearch_snapshot.arn,
      "${aws_s3_bucket.opensearch_snapshot.arn}/*",
    ]
  }
}
