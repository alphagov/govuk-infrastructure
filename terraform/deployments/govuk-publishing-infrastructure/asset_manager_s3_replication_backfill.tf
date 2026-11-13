module "assets_s3_replication_backfill_bucket" {
  count = var.assets_s3_replication_backfill ? 1 : 0

  source = "../../shared-modules/s3"

  name              = "govuk-${var.govuk_environment}-assets-backfill-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  govuk_environment = var.govuk_environment
}

resource "aws_iam_policy" "assets_s3_replication_backfill" {
  count = var.assets_s3_replication_backfill ? 1 : 0

  name = "ReplicateProductionAssetsBackfill"

  policy = data.aws_iam_policy_document.assets_s3_replication_backfill[0].json
}

resource "aws_iam_role_policy_attachment" "assets_s3_replication_backfill" {
  count = var.assets_s3_replication_backfill ? 1 : 0

  role       = aws_iam_role.assets_s3_replication[0].name
  policy_arn = aws_iam_policy.assets_s3_replication_backfill[0].arn
}

data "aws_iam_policy_document" "assets_s3_replication_backfill" {
  count = var.assets_s3_replication_backfill ? 1 : 0

  statement {
    sid       = "InitiateReplication"
    actions   = ["s3:InitiateReplication"]
    resources = ["${module.assets_s3_bucket.arn}/*"]
  }

  statement {
    sid = "ConfigureSourceReplication"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:PutInventoryConfiguration",
    ]
    resources = [
      module.assets_s3_bucket.arn,
    ]
  }

  statement {
    sid = "ReadManifest"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "${module.assets_s3_replication_backfill_bucket[0].arn}/manifest/*"
    ]
  }

  statement {
    sid = "WriteReportAndManifest"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${module.assets_s3_replication_backfill_bucket[0].arn}/report/*",
      "${module.assets_s3_replication_backfill_bucket[0].arn}/manifest/*",
    ]
  }
}
