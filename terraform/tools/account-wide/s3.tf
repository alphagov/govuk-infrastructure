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

module "state_file_bucket" {
  source = "../../shared-modules/s3"
  name   = "govuk-tools-state-files"

  govuk_environment = var.govuk_account

  depends_on = [module.logging_bucket]
}
