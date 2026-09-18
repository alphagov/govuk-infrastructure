locals {
  assets_bucket_name = "govuk-assets-${var.govuk_environment}"
  assets_bucket_arn  = "arn:aws:s3:::${local.assets_bucket_name}"

  s3_assets_replicate_to_other_envs = length(var.replicate_assets_to_environments) > 0
  s3_assets_replication_enabled     = var.backup_assets_to_secondary_bucket || local.s3_assets_replicate_to_other_envs
}

module "govuk_aws_accounts" {
  source = "../../shared-modules/govuk-aws-accounts"
}

import {
  for_each = local.s3_assets_replication_enabled ? [1] : []

  to = aws_iam_role.assets_s3_replication[0]
  id = "govuk-${var.govuk_environment}-assets-s3-replication"
}

resource "aws_iam_role" "assets_s3_replication" {
  count = local.s3_assets_replication_enabled ? 1 : 0

  name               = "govuk-${var.govuk_environment}-assets-s3-replication"
  description        = "Service role for S3 replication of govuk-assets-production to staging/integration and to govuk-assets-backup-production."
  assume_role_policy = data.aws_iam_policy_document.assets_s3_replication_assume_role[0].json
}

data "aws_iam_policy_document" "assets_s3_replication_assume_role" {
  count = local.s3_assets_replication_enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

import {
  for_each = local.s3_assets_replication_enabled ? [1] : []

  to = aws_iam_policy.assets_s3_replication[0]
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ReplicateProductionAssets"
}

resource "aws_iam_policy" "assets_s3_replication" {
  count = local.s3_assets_replication_enabled ? 1 : 0

  name = "ReplicateProductionAssets"

  policy = data.aws_iam_policy_document.assets_s3_replication[0].json

}

data "aws_iam_policy_document" "assets_s3_replication" {
  count = local.s3_assets_replication_enabled ? 1 : 0

  statement {
    sid = "ReadSourceBucketReplicationConfig"

    actions = [
      "s3:ListBucket",
      "s3:GetReplicationConfiguration"
    ]

    resources = [module.assets_s3_bucket.arn]
  }

  statement {
    sid = "ReadSourceBucketObjectMetadataForReplication"

    actions = ["s3:GetObjectVersion*"]

    resources = ["${module.assets_s3_bucket.arn}/*"]
  }

  statement {
    sid = "ReplicateObjectsToDestinationBuckets"

    actions = [
      "s3:Replicate*",
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:GetObjectVersionTagging"
    ]

    resources = concat([
      for config in var.replicate_assets_to_environments :
      "arn:aws:s3:::govuk-assets-${config.destination_environment}/*"
    ], var.backup_assets_to_secondary_bucket ? ["${data.aws_s3_bucket.assets_s3_backup[0].arn}/*"] : [])
  }
}

import {
  for_each = local.s3_assets_replication_enabled ? [1] : []

  to = aws_iam_role_policy_attachment.assets_s3_replication[0]
  id = "govuk-${var.govuk_environment}-assets-s3-replication/arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ReplicateProductionAssets"
}

resource "aws_iam_role_policy_attachment" "assets_s3_replication" {
  count = local.s3_assets_replication_enabled ? 1 : 0

  role       = aws_iam_role.assets_s3_replication[0].name
  policy_arn = aws_iam_policy.assets_s3_replication[0].arn
}

// We need to bring this into terraform
data "aws_s3_bucket" "assets_s3_backup" {
  provider = aws.replica

  count = var.backup_assets_to_secondary_bucket ? 1 : 0

  bucket = "govuk-assets-backup-${var.govuk_environment}"
}

moved {
  from = module.assets
  to   = module.assets_s3_bucket
}

module "assets_s3_bucket" {
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

  extra_bucket_policies = (
    length(var.allow_assets_to_be_replicated_from_accounts) > 0
    ? [data.aws_iam_policy_document.allow_cross_account_assets_s3_replication[0].json]
    : null
  )

  ownership_controls = {
    rules = [
      {
        object_ownership = "ObjectWriter"
      },
    ]
  }

  replication_config = local.s3_assets_replication_enabled ? {
    role = aws_iam_role.assets_s3_replication[0].arn
    rules = concat(
      var.backup_assets_to_secondary_bucket ? [
        {
          id       = "${var.govuk_environment}-assets-to-${var.govuk_environment}-backup"
          status   = "Enabled"
          priority = "10"
          destination = {
            bucket = data.aws_s3_bucket.assets_s3_backup[0].arn
          }
          delete_marker_replication = {
            status = "Enabled"
          }
        }
      ] : [],
      [
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
  } : null
}

data "aws_iam_policy_document" "allow_cross_account_assets_s3_replication" {
  count = length(var.allow_assets_to_be_replicated_from_accounts) > 0 ? 1 : 0

  statement {
    sid = "SetPermissionsForObjects"

    actions = [
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
    ]

    resources = ["${module.assets_s3_bucket.arn}/*"]

    principals {
      type = "AWS"

      identifiers = [
        for env in var.allow_assets_to_be_replicated_from_accounts :
        "arn:aws:iam::${module.govuk_aws_accounts.account_name_to_id[env]}:role/govuk-${env}-assets-s3-replication"
      ]
    }
  }

  statement {
    sid = "SetPermissionsOnBucket"

    actions = [
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning",
    ]

    resources = [module.assets_s3_bucket.arn]

    principals {
      type = "AWS"

      identifiers = [
        for env in var.allow_assets_to_be_replicated_from_accounts :
        "arn:aws:iam::${module.govuk_aws_accounts.account_name_to_id[env]}:role/govuk-${env}-assets-s3-replication"
      ]
    }
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
