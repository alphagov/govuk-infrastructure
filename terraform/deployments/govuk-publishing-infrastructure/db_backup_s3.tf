locals {
  db_backup_service_account_name = "db-backup"
  env_also_reads_from = {
    "production"  = "govuk-production-database-backups-replica"
    "staging"     = "govuk-production-database-backups"
    "integration" = "govuk-staging-database-backups"
  }
}

module "db_backup_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name            = "${local.db_backup_service_account_name}-${data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id}"
  role_description     = "Role for database backup jobs. Corresponds to ${local.db_backup_service_account_name} k8s ServiceAccount."
  max_session_duration = 28800

  role_policy_arns = { policy = aws_iam_policy.db_backup_s3.arn }
  oidc_providers = {
    main = {
      provider_arn               = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn
      namespace_service_accounts = ["apps:${local.db_backup_service_account_name}"]
    }
  }
}

data "aws_iam_policy_document" "db_backup_s3" {
  statement {
    sid = "Read"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObject*Attributes",
    ]
    resources = [
      "arn:aws:s3:::govuk-${var.govuk_environment}-database-backups",
      "arn:aws:s3:::govuk-${var.govuk_environment}-database-backups/*",
      "arn:aws:s3:::${local.env_also_reads_from[var.govuk_environment]}",
      "arn:aws:s3:::${local.env_also_reads_from[var.govuk_environment]}/*",
    ]
  }
  statement {
    sid       = "Write"
    actions   = ["s3:*MultipartUpload*", "s3:PutObject"]
    resources = ["arn:aws:s3:::govuk-${var.govuk_environment}-database-backups/*"]
  }
}

resource "aws_iam_policy" "db_backup_s3" {
  name        = "db_backup_s3"
  description = "Permissions over this environment's govuk-*-database-backups bucket."
  policy      = data.aws_iam_policy_document.db_backup_s3.json
}
