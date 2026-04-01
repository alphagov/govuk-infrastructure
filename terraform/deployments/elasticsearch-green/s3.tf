locals {
  manual_snapshots_bucket_name = "govuk-${var.govuk_environment}-${var.stackname}-elasticsearch6-manual-snapshots"
  manual_snapshots_bucket_arn  = "arn:aws:s3:::${local.manual_snapshots_bucket_name}"
}

module "secure_s3_bucket_manual_snapshots" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = local.manual_snapshots_bucket_name

  extra_bucket_policies = [data.aws_iam_policy_document.manual_snapshots_cross_account_access.json]
}

moved {
  from = aws_s3_bucket.manual_snapshots
  to   = module.secure_s3_bucket_manual_snapshots.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_logging.manual_snapshots
  to   = module.secure_s3_bucket_manual_snapshots.aws_s3_bucket_logging.this
}

moved {
  from = aws_s3_bucket_policy.manual_snapshots_cross_account_access
  to   = module.secure_s3_bucket_manual_snapshots.aws_s3_bucket_policy.bucket_policy
}

data "aws_iam_policy_document" "manual_snapshots_cross_account_access" {
  statement {
    sid = "CrossAccountAccess"
    principals {
      type = "AWS"
      identifiers = [
        "172025368201", # Production
        "696911096973", # Staging
        "210287912431", # Integration
      ]
    }
    # This bucket is only for copying the indices from prod to
    # staging/integration. Backup snapshots of prod are stored separately, so
    # the (required) put/delete permissions here don't represent a problem.
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      local.manual_snapshots_bucket_arn,
      "${local.manual_snapshots_bucket_arn}/*",
    ]
  }
}
