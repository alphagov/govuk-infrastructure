locals {
  log_bucket_name = "govuk-${var.govuk_account}-aws-logging"
  log_bucket_arn  = "arn:aws:s3:::${local.log_bucket_name}"
}

module "logging_bucket" {
  source = "../../shared-modules/s3"

  govuk_environment      = var.govuk_account
  name                   = local.log_bucket_name
  disable_bucket_logging = true

  extra_bucket_policies = [
    data.aws_iam_policy_document.s3_aws_logging.json
  ]
  force_destroy = false

  lifecycle_rules = [{
    id     = "IntoGlacier"
    status = "Enabled"

    expiration = {
      days = 90
    }

    noncurrent_version_expiration = {
      noncurrent_days = 1
    }

    transition = [
      {
        days          = 30
        storage_class = "GLACIER_IR"
      }
    ]
  }]
}

data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "s3_aws_logging" {
  statement {
    sid       = "ELBLogDeliveryWrite"
    actions   = ["s3:PutObject"]
    resources = ["${local.log_bucket_arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
  }

  statement {
    sid       = "AccountLogDeliveryWrite"
    actions   = ["s3:PutObject"]
    resources = ["${local.log_bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}