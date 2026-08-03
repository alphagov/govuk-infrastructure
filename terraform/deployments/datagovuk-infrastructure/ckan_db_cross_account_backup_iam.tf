locals {
  ckan_database_cross_account_backup_role_name            = "ckan-db-backup-xaccount-sync-${local.cluster_id}"
  ckan_database_cross_account_backup_service_account_name = "ckan-db-backup-xaccount-sync"
  source_db_backups_s3_bucket_arn                         = "arn:aws:s3:::govuk-${var.govuk_environment}-database-backups"
}

module "ckan_database_cross_account_backup_role" {
  count = var.enable_cross_account_database_backup_sync ? 1 : 0

  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "~> 6.0"
  name               = local.ckan_database_cross_account_backup_role_name
  use_name_prefix    = false
  description        = "Role for CKAN S3 access. Corresponds to ${var.ckan_service_account_namespace}/${local.ckan_database_cross_account_backup_service_account_name} k8s ServiceAccount."
  enable_oidc        = true
  oidc_provider_urls = [local.oidc_provider]
  policies = {
    (aws_iam_policy.ckan_db_backup_xaccount_sync[0].name) = aws_iam_policy.ckan_db_backup_xaccount_sync[0].arn
  }
  oidc_subjects = ["system:serviceaccount:${var.ckan_service_account_namespace}:${local.ckan_database_cross_account_backup_service_account_name}"]
}

resource "aws_iam_policy" "ckan_db_backup_xaccount_sync" {
  count = var.enable_cross_account_database_backup_sync ? 1 : 0

  name        = "datagovuk-ckan-db-backup-xaccount-sync-${var.govuk_environment}"
  description = "Allow CKAN database backups to be synced to a new DGU AWS account"
  policy      = data.aws_iam_policy_document.ckan_db_backup_xaccount_sync[0].json
}

data "aws_iam_policy_document" "ckan_db_backup_xaccount_sync" {
  count = var.enable_cross_account_database_backup_sync ? 1 : 0

  statement {
    sid     = "AllowReadingFromSource"
    effect  = "Allow"
    actions = ["s3:CopyObject", "s3:GetObject", "s3:GetObjectTagging", "s3:HeadObject", "s3:ListObjects"]

    resources = ["${local.source_db_backups_s3_bucket_arn}/ckan-postgres/*"]
  }

  statement {
    sid       = "AllowActingOnSourceBucket"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [local.source_db_backups_s3_bucket_arn]
  }

  statement {
    sid     = "AllowWritingToDestination"
    effect  = "Allow"
    actions = ["s3:HeadObject", "s3:PutObject", "s3:PutObjectTagging", "s3:ListObjects"]
    resources = [
      "${var.cross_account_database_backup_sync_target_s3_bucket_arn}/ckan-postgres/*"
    ]
  }

  statement {
    sid       = "AllowActingOnDestinationBucket"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [var.cross_account_database_backup_sync_target_s3_bucket_arn]
  }
}
