locals {
  rds_parquet_exporter_service_account_name = "rds-parquet-exporter"
  parquet_files_bucket_prefix               = "parquet"
}

module "rds_parquet_exporter_job_starter_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  name                 = "${local.rds_parquet_exporter_service_account_name}-job-starter-${data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id}"
  use_name_prefix      = false
  description          = "Role for rds-parquet-exporter job to initiate Export. Corresponds to ${local.rds_parquet_exporter_service_account_name} k8s ServiceAccount."
  max_session_duration = 28800

  oidc_providers = {
    main = {
      provider_arn               = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn
      namespace_service_accounts = ["apps:${local.rds_parquet_exporter_service_account_name}"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "rds_parquet_exporter_job_starter" {
  role       = module.rds_parquet_exporter_job_starter_iam_role.name
  policy_arn = aws_iam_policy.rds_parquet_exporter_job_starter.arn
}

data "aws_iam_policy_document" "rds_parquet_exporter_job_starter" {
  statement {
    sid = "RDSExportPermissions"
    actions = [
      "rds:DescribeDBSnapshots",
      "rds:DescribeExportTasks",
      "rds:StartExportTask"
    ]
    resources = ["*"]
  }
  statement {
    actions = ["iam:PassRole"]
    resources = [
      aws_iam_role.rds_parquet_exporter_export_task.arn,
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["export.rds.amazonaws.com", "rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "rds_parquet_exporter_job_starter" {
  name        = "rds_parquet_exporter_job_starter"
  description = "Permissions for the RDS parquet exporter job to initiate exports."
  policy      = data.aws_iam_policy_document.rds_parquet_exporter_job_starter.json
}

resource "aws_iam_role" "rds_parquet_exporter_export_task" {
  name                 = "rds-parquet-exporter-export-task-${data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id}"
  description          = "Role for RDS to use when exporting parquet files to S3"
  assume_role_policy   = data.aws_iam_policy_document.allow_rds_exporter_access.json
  max_session_duration = 28800
}

resource "aws_iam_role_policy_attachment" "rds_parquet_exporter_export_task" {
  role       = aws_iam_role.rds_parquet_exporter_export_task.name
  policy_arn = aws_iam_policy.rds_parquet_exporter_export_task.arn
}

data "aws_iam_policy_document" "rds_parquet_exporter_export_task" {
  statement {
    sid = "S3AccessForExport"
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:DeleteObject",
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::govuk-${var.govuk_environment}-database-backups",
      "arn:aws:s3:::govuk-${var.govuk_environment}-database-backups/${local.parquet_files_bucket_prefix}/*",
    ]
  }
  statement {
    sid = "AllowAccessToKMSKey"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.rds_parquet_exporter.arn]
  }
}

resource "aws_iam_policy" "rds_parquet_exporter_export_task" {
  name        = "rds_parquet_exporter_export_task"
  description = "Permissions for the RDS parquet exporter export task to write to s3."
  policy      = data.aws_iam_policy_document.rds_parquet_exporter_export_task.json
}

data "aws_iam_policy_document" "allow_rds_exporter_access" {
  statement {
    sid    = "AllowRDSExporterAccess"
    effect = "Allow"

    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["export.rds.amazonaws.com"]
    }
  }
}
