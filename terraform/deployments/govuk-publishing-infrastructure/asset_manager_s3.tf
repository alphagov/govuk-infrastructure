locals {
  assets_bucket_name = "govuk-assets-${var.govuk_environment}"
  assets_bucket_arn  = "arn:aws:s3:::${local.assets_bucket_name}"
}

module "govuk_aws_accounts" {
  source = "../../shared-modules/govuk-aws-accounts"
}

// We need to bring this into terraform, and when we do we can add a variable to flag it instead of
// checking for production as an env
data "aws_iam_role" "assets_s3_replication" {
  count = var.govuk_environment == "production" ? 1 : 0

  name = "govuk-${var.govuk_environment}-assets-s3-replication"
}

// We need to bring this into terraform, and when we do we can add a variable to flag it instead of
// checking for production as an env
data "aws_s3_bucket" "assets_s3_backup" {
  provider = aws.replica

  count = var.govuk_environment == "production" ? 1 : 0

  bucket = "govuk-assets-backup-production"
}

import {
  for_each = var.govuk_environment == "production" ? [1] : []

  to = module.assets.aws_s3_bucket_replication_configuration.this[0]
  id = local.assets_bucket_name
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

  # There is a whole rule missing here, we also have a rule prod-assets-to-prod-backup
  # but that uses a different role and terraform doesn't support setting different roles
  # for different rules. We will need to consolidate the roles into one and then import it
  replication_config = length(var.replicate_assets_to_environments) == 0 ? null : {
    role = data.aws_iam_role.assets_s3_replication[0].arn
    rules = concat([
      {
        id       = "prod-assets-to-prod-backup"
        status   = "Enabled"
        priority = "10"
        destination = {
          bucket = data.aws_s3_bucket.assets_s3_backup[0].arn
        }
        delete_marker_replication = {
          status = "Enabled"
        }
      }], [
      for config in var.replicate_assets_to_environments : {
        id       = "${var.govuk_environment}-assets-to-${config.destination_environment}"
        status   = "Enabled"
        priority = config.priority
        destination = {
          bucket  = "arn:aws:s3:::govuk-assets-${config.destination_environment}"
          account = module.govuk_aws_accounts.account_name_to_id[config.destination_environment]
          access_control_translation = {
            owner = "Destination"
          }
        }
        delete_marker_replication = {
          status = "Enabled"
        }
      }
    ])
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
