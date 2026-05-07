locals {
  mobile_backend_remote_config_bucket_name = "govuk-app-remote-config-${var.govuk_environment}"
}

module "mobile_backend_remote_config" {
  source            = "../../shared-modules/s3"
  govuk_environment = var.govuk_environment
  name              = local.mobile_backend_remote_config_bucket_name
  access_logging_config = {
    target_prefix = "s3/mobile-backend-remote-config-${var.govuk_environment}/"
  }
  extra_bucket_policies = [
    data.aws_iam_policy_document.mobile_backend_remote_config_fastly_read.json
  ]
}

moved {
  from = aws_s3_bucket.mobile_backend_remote_config
  to   = module.mobile_backend_remote_config.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_versioning.mobile_backend_remote_config
  to   = module.mobile_backend_remote_config.aws_s3_bucket_versioning.this
}


moved {
  from = aws_s3_bucket_logging.mobile_backend_remote_config
  to   = module.mobile_backend_remote_config.aws_s3_bucket_logging.this
}

data "aws_iam_policy_document" "mobile_backend_remote_config_fastly_read" {
  statement {
    sid     = "S3FastlyReadBucket"
    actions = ["s3:GetObject"]

    resources = [
      "arn:aws:s3:::${local.mobile_backend_remote_config_bucket_name}",
      "arn:aws:s3:::${local.mobile_backend_remote_config_bucket_name}/*"
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"

      values = data.fastly_ip_ranges.fastly.cidr_blocks
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = ["true"]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

moved {
  from = aws_s3_bucket_policy.mobile_backend_remote_config_read
  to   = module.mobile_backend_remote_config.aws_s3_bucket_policy.bucket_policy
}
