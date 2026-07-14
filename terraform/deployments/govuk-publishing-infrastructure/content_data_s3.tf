locals {
  content_data_csvs_s3_bucket_name = "govuk-${var.govuk_environment}-content-data-csvs"
  content_data_csvs_s3_bucket_arn  = "arn:aws:s3:::${local.content_data_csvs_s3_bucket_name}"
}

module "content_data_csvs_s3_bucket" {
  source = "../../shared-modules/s3"

  name              = local.content_data_csvs_s3_bucket_name
  govuk_environment = var.govuk_environment

  enable_public_access_block = false

  extra_bucket_policies = [data.aws_iam_policy_document.content_data_csvs_s3_bucket_public_read.json]

  lifecycle_rules = [
    {
      id     = "all"
      status = "Enabled"

      expiration = {
        days = 7
      }
    },
    {
      id     = "all-expired"
      status = "Enabled"

      noncurrent_version_expiration = {
        noncurrent_days = 7
      }
    },
  ]
}

data "aws_iam_policy_document" "content_data_csvs_s3_bucket_public_read" {
  statement {
    sid = "AllowPublicObjectRead"

    actions = ["s3:GetObject"]

    resources = ["${local.content_data_csvs_s3_bucket_arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  statement {
    sid = "AllowPublicListBucket"

    actions = ["s3:ListBucket"]

    resources = [local.content_data_csvs_s3_bucket_arn]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

moved {
  from = aws_s3_bucket.content_data_csvs
  to   = module.content_data_csvs_s3_bucket.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_logging.content_data_csvs
  to   = module.content_data_csvs_s3_bucket.aws_s3_bucket_logging.this[0]
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.content_data_csvs
  to   = module.content_data_csvs_s3_bucket.aws_s3_bucket_lifecycle_configuration.this[0]
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
    resources = [local.content_data_csvs_s3_bucket_arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["${local.content_data_csvs_s3_bucket_arn}/*"]
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
