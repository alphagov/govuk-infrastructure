locals {
  opensearch_snapshots_bucket_name = "govuk-${var.govuk_environment}-${var.service}-opensearch-snapshots"
  opensearch_snapshots_bucket_arn  = "arn:aws:s3:::${local.opensearch_snapshots_bucket_name}"
}

# S3 bucket configuration for manual snapshot process
module "secure_s3_bucket_opensearch_snapshots" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = local.opensearch_snapshots_bucket_name

  extra_bucket_policies = [data.aws_iam_policy_document.opensearch_snapshot_bucket_policy.json]
}

data "aws_iam_policy_document" "opensearch_snapshot_bucket_policy" {
  statement {
    sid = "CrossAccountAccess"
    principals {
      type = "AWS"
      identifiers = [
        "172025368201", # Production
        "696911096973", # Staging
        "210287912431", # Integration
        "430354129336", # Test
      ]
    }
    # This bucket is only for copying the indices from prod to staging,
    # integration and test. Backup snapshot of prod are stored separately, so
    # the (required) put/delete permissions here don't represent a problem.
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      local.opensearch_snapshots_bucket_arn,
      "${local.opensearch_snapshots_bucket_arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}
