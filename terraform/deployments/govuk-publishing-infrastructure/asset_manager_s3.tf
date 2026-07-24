locals {
  assets_bucket_name = "govuk-assets-${var.govuk_environment}"
  assets_bucket_arn  = "arn:aws:s3:::${local.assets_bucket_name}"
}

module "assets" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = local.assets_bucket_name

  versioning_enabled         = true
  enable_public_access_block = false

  disable_bucket_logging = startswith(var.govuk_environment, "eph-") ? true : false
  access_logging_config = {
    target_bucket = "govuk-${var.govuk_environment}-aws-logging"
    target_prefix = "s3/govuk-assets-${var.govuk_environment}/"
  }

  ownership_controls = {
    rules = [
      {
        object_ownership = "ObjectWriter"
      },
    ]
  }
}

data "aws_iam_policy_document" "asset_manager_s3" {
  statement {
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [local.assets_bucket_arn]
  }

  statement {
    actions = [
      "s3:*MultipartUpload*",
      "s3:*Object",
      "s3:*ObjectAcl",
      "s3:*ObjectVersion",
      "s3:GetObject*Attributes"
    ]
    resources = ["${local.assets_bucket_arn}/*"]

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

moved {
  from = aws_s3_bucket.assets
  to   = module.assets.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.assets
  to   = module.assets.aws_s3_bucket_lifecycle_configuration.this[0]
}

moved {
  from = aws_s3_bucket_logging.assets
  to   = module.assets.aws_s3_bucket_logging.this[0]
}

moved {
  from = aws_s3_bucket_versioning.assets
  to   = module.assets.aws_s3_bucket_versioning.this
}
