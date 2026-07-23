locals {
  datagovuk_static_bucket_name = "datagovuk-${var.govuk_environment}-ckan-static-data"
  datagovuk_static_bucket_arn  = "arn:aws:s3:::${local.datagovuk_static_bucket_name}"
}

module "datagovuk_static" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = local.datagovuk_static_bucket_name

  versioning_enabled         = true
  enable_public_access_block = false
  disable_bucket_logging     = startswith(var.govuk_environment, "eph-") ? true : false
  access_logging_config = {
    target_bucket = "govuk-${var.govuk_environment}-aws-logging"
    target_prefix = "s3/datagovuk-${var.govuk_environment}-ckan-static-data/"
  }

  ownership_controls = {
    rules = [
      {
        object_ownership = "ObjectWriter"
      },
    ]
  }

  extra_bucket_policies = [
    data.aws_iam_policy_document.datagovuk_static.json
  ]
}

data "aws_iam_policy_document" "datagovuk_static" {
  statement {
    sid     = "S3FastlyReadBucket"
    actions = ["s3:GetObject"]

    resources = [
      local.datagovuk_static_bucket_arn,
      "${local.datagovuk_static_bucket_arn}/*"
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"

      values = data.fastly_ip_ranges.fastly.cidr_blocks
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

moved {
  from = aws_s3_bucket_policy.govuk_datagovuk_static_read_policy
  to   = module.datagovuk_static.aws_s3_bucket_policy.bucket_policy
}

moved {
  from = aws_s3_bucket.datagovuk_static
  to   = module.datagovuk_static.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_versioning.datagovuk_static
  to   = module.datagovuk_static.aws_s3_bucket_versioning.this
}

moved {
  from = aws_s3_bucket_logging.datagovuk_static
  to   = module.datagovuk_static.aws_s3_bucket_logging.this
}

