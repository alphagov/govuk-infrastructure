locals {
  bucket_name = "govuk-${var.govuk_environment}-elasticsearch6-manual-snapshots"
}

resource "aws_s3_bucket" "manual_snapshots" {
  bucket = local.bucket_name
  tags = {
    Name = local.bucket_name
  }
}

resource "aws_s3_bucket_logging" "manual_snapshots" {
  bucket        = aws_s3_bucket.manual_snapshots.id
  target_bucket = data.tfe_outputs.logging.nonsensitive_values.aws_logging_bucket_id
  target_prefix = "s3/${local.bucket_name}/"
}

resource "aws_s3_bucket_policy" "manual_snapshots_cross_account_access" {
  bucket = aws_s3_bucket.manual_snapshots.id
  policy = data.aws_iam_policy_document.manual_snapshots_cross_account_access.json
}

data "aws_iam_policy_document" "manual_snapshots_cross_account_access" {
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
    # staging/integration. Backup snapshots of prod are stored separately, so
    # the (required) put/delete permissions here don't represent a problem.
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      aws_s3_bucket.manual_snapshots.arn,
      "${aws_s3_bucket.manual_snapshots.arn}/*",
    ]
  }

  statement {
    sid    = "DenyNonTLS"
    effect = "Deny"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.manual_snapshots.arn}/*"]
    condition {
      test     = "Bool"
      values   = [false]
      variable = "aws:SecureTransport"
    }
  }
}
