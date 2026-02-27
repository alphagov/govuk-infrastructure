locals {
  bucket_suffix        = var.s3_bucket_custom_suffix == null ? "opensearch-snapshots" : var.s3_bucket_custom_suffix
  snapshot_bucket_name = "govuk-${var.govuk_environment}-${var.opensearch_domain_name}-${local.bucket_suffix}"
}

module "snapshot_bucket" {
  # soource = "github.com/alphagov/govuk-infrastructure/terraform/shared-modules/s3?depth=1&ref=main"
  source = "../s3"

  name              = local.snapshot_bucket_name
  govuk_environment = var.govuk_environment

  extra_bucket_policies = [data.aws_iam_policy_document.snapshot_bucket_policy.json]
}

data "aws_iam_policy_document" "snapshot_bucket_policy" {
  statement {
    sid = "ReadSnapshots"

    principals {
      type = "AWS"
      identifiers = sort(distinct(concat(
        [data.aws_caller_identity.current.account_id],
        var.account_ids_allowed_to_read_domain_snapshots
      )))
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.snapshot_bucket_name}",
      "arn:aws:s3:::${local.snapshot_bucket_name}/*",
    ]
  }

  statement {
    sid = "WriteSnapshots"

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }

    actions = [
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = ["arn:aws:s3:::${local.snapshot_bucket_name}/*"]
  }
}
