locals {
  datagovuk-organogram_bucket_name = "datagovuk-${var.govuk_environment}-ckan-organogram"
  datagovuk-organogram_bucket_arn  = "arn:aws:s3:::${local.datagovuk-organogram_bucket_name}"
}

data "aws_iam_policy_document" "s3_fastly_read_policy_doc" {
  statement {
    sid     = "S3FastlyReadBucket"
    actions = ["s3:GetObject"]
    resources = [
      local.datagovuk-organogram_bucket_arn,
      "${local.datagovuk-organogram_bucket_arn}/*",
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

module "secure_s3_bucket_datagovuk-organogram" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = local.datagovuk-organogram_bucket_name

  versioning_enabled         = true
  enable_public_access_block = false
  disable_bucket_logging     = startswith(var.govuk_environment, "eph-") ? true : false

  cors_rules = {
    allowed_methods = ["GET"]
    allowed_origins = var.organogram_bucket_cors_origins
  }

  ownership_controls = {
    rules = [
      {
        object_ownership = "BucketOwnerEnforced"
      },
    ]
  }

  extra_bucket_policies = [
    data.aws_iam_policy_document.s3_fastly_read_policy_doc.json
  ]
}

moved {
  from = aws_s3_bucket.datagovuk-organogram
  to   = module.secure_s3_bucket_datagovuk-organogram.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_versioning.datagovuk_organogram
  to   = module.secure_s3_bucket_datagovuk-organogram.aws_s3_bucket_versioning.this
}

moved {
  from = aws_s3_bucket_policy.govuk_datagovuk_organogram_read_policy
  to   = module.secure_s3_bucket_datagovuk-organogram.aws_s3_bucket_policy.bucket_policy
}

moved {
  from = aws_s3_bucket_ownership_controls.datagovuk_organogram
  to   = module.secure_s3_bucket_datagovuk-organogram.aws_s3_bucket_ownership_controls.owner
}

moved {
  from = aws_s3_bucket_cors_configuration.datagovuk_organogram
  to   = module.secure_s3_bucket_datagovuk-organogram.aws_s3_bucket_cors_configuration.this[0]
}

moved {
  from = aws_s3_bucket_logging.datagovuk_organogram
  to   = module.secure_s3_bucket_datagovuk-organogram.aws_s3_bucket_logging.this[0]
}
