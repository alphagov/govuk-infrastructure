locals {
  secure_s3_bucket_app_assets_name = "govuk-app-assets-${var.govuk_environment}"
  secure_s3_bucket_app_assets_arn  = "arn:aws:s3:::${local.secure_s3_bucket_app_assets_name}"
}

module "secure_s3_bucket_app_assets" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = local.secure_s3_bucket_app_assets_name

  versioning_enabled   = true
  versioning_suspended = true

  enable_public_access_block = false
  extra_bucket_policies      = [data.aws_iam_policy_document.app_assets.json]

  access_logging_config = {
    target_bucket = "govuk-s3-integration-troubleshoot-logs"
    target_prefix = ""
  }

  tags = {
    System = "Static serving"
    Name   = "App static assets for ${var.govuk_environment}"
  }
}

moved {
  from = aws_s3_bucket.app_assets
  to   = module.secure_s3_bucket_app_assets.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_versioning.app_assets
  to   = module.secure_s3_bucket_app_assets.aws_s3_bucket_versioning.this
}

moved {
  from = aws_s3_bucket_policy.app_assets
  to   = module.secure_s3_bucket_app_assets.aws_s3_bucket_policy.bucket_policy
}

import {
  to = module.secure_s3_bucket_app_assets.aws_s3_bucket_server_side_encryption_configuration.this
  id = local.secure_s3_bucket_app_assets_name
}

# TODO: instead of granting write access to nodes, use IRSA (IAM Roles for
# Service Accounts aka pod identity) so that only Argo CD can write.
data "aws_iam_policy_document" "app_assets" {
  statement {
    sid = "PublicCanReadButNotList"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${local.secure_s3_bucket_app_assets_arn}/*"]
  }
  statement {
    sid = "EKSNodesCanList"
    principals {
      type        = "AWS"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_arn]
    }
    actions   = ["s3:ListBucket"]
    resources = [local.secure_s3_bucket_app_assets_arn]
  }
  statement {
    sid = "EKSNodesCanWrite"
    principals {
      type        = "AWS"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_arn]
    }
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${local.secure_s3_bucket_app_assets_arn}/*"]
  }
}
