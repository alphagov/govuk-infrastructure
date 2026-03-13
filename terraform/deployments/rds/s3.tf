module "secure_s3_bucket_rds_dumps" {
  count  = var.create_secure_db_dumps_bucket ? 1 : 0
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = "govuk-${var.govuk_environment}-rds-dumps"

  versioning_enabled         = false
  enable_public_access_block = true

  lifecycle_rules = [
    {
      id     = "govuk-${var.govuk_environment}-rds-dumps-lifecycle"
      status = "Enabled"
      expiration = {
        days = 30
      }
    }
  ]

  extra_bucket_policies = [data.aws_iam_policy_document.s3_rds_dump_iam_policy.json]
}

data "aws_iam_policy_document" "s3_rds_dump_iam_policy" {
  statement {
    sid    = "AllowDbDumpAccessFromEKSCronJob"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::govuk-${var.govuk_environment}-rds-dumps",
      "arn:aws:s3:::govuk-${var.govuk_environment}-rds-dumps/*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::210287912431:role/db-backup-govuk", # Integration
        "arn:aws:iam::696911096973:role/db-backup-govuk", # Staging
        "arn:aws:iam::172025368201:role/db-backup-govuk", # Prod
      ]
    }
  }
}
