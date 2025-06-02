resource "aws_s3_bucket" "content_data_csvs" {
  bucket = "govuk-${var.govuk_environment}-content-data-csvs"
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

# IAM role for content-data-admin

data "aws_iam_policy_document" "content_data_admin_role_assume" {
  statement {
    effect = "Allow"
    actions = [
      "sts:TagSession",
      "sts:AssumeRoleWithWebIdentity"
    ]
    principals {
      type        = "Federated"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider}:sub"
      values   = ["system:serviceaccount:apps:content-data-admin"]
    }
  }
}

resource "aws_iam_role" "content_data_admin" {
  name               = "content-data-admin-${var.govuk_environment}"
  assume_role_policy = data.aws_iam_policy_document.content_data_admin_role_assume.json
}

data "aws_iam_policy_document" "content_data_admin" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [aws_s3_bucket.content_data_csvs.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["${aws_s3_bucket.content_data_csvs.arn}/*"]
  }
}

resource "aws_iam_policy" "content_data_admin" {
  name        = "content_data_admin_${var.govuk_environment}"
  path        = "/"
  description = "Policy to allow content-data-admin access to CSVs S3 bucket"

  policy = data.aws_iam_policy_document.content_data_admin.json
}

resource "aws_iam_role_policy_attachment" "content_data_admin" {
  role       = aws_iam_role.content_data_admin.name
  policy_arn = aws_iam_policy.content_data_admin.arn
}
