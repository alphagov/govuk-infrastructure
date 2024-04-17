resource "aws_s3_bucket" "assets" {
  bucket = "govuk-assets-${var.govuk_environment}"
}

import {
  to = aws_s3_bucket.assets
  id = "govuk-assets-${var.govuk_environment}"
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_logging" "assets" {
  bucket        = aws_s3_bucket.assets.id
  target_bucket = "govuk-${var.govuk_environment}-aws-logging"
  target_prefix = "s3/govuk-assets-${var.govuk_environment}/"
}

data "aws_iam_policy_document" "asset_manager_s3" {
  statement {
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [aws_s3_bucket.assets.arn]
  }

  statement {
    actions = [
      "s3:*MultipartUpload*",
      "s3:*Object",
      "s3:*ObjectAcl",
      "s3:*ObjectVersion",
      "s3:GetObject*Attributes"
    ]
    resources = ["${aws_s3_bucket.assets.arn}/*"]

  }
}

resource "aws_iam_policy" "asset_manager_s3" {
  name        = "asset_manager_s3"
  description = "Asset manager s3 policy"
  policy      = data.aws_iam_policy_document.asset_manager_s3.json
}

resource "aws_iam_role_policy_attachment" "asset_manager_s3" {
  role       = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_name
  policy_arn = aws_iam_policy.asset_manager_s3.arn
}
