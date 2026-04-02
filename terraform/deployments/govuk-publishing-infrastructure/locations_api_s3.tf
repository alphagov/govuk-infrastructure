locals {
  secure_s3_bucket_locations_api_import_csvs_name = "govuk-${var.govuk_environment}-locations-api-import-csvs"
  secure_s3_bucket_locations_api_import_csvs_arn  = "arn:aws:s3:::${local.secure_s3_bucket_locations_api_import_csvs_name}"
}

module "secure_s3_bucket_locations_api_import_csvs" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = local.secure_s3_bucket_locations_api_import_csvs_name

  versioning_enabled   = true
  versioning_suspended = true

  extra_bucket_policies = [data.aws_iam_policy_document.app_assets.json]

  tags = {
    System      = "Locations API"
    Description = "CSVs for importing postcode information into Locations API"
  }
}

moved {
  from = aws_s3_bucket.locations_api_import_csvs
  to   = module.secure_s3_bucket_locations_api_import_csvs.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_versioning.locations_api_import_csvs
  to   = module.secure_s3_bucket_locations_api_import_csvs.aws_s3_bucket_versioning.this
}

moved {
  from = aws_s3_bucket_policy.location_api_import_csvs
  to   = module.secure_s3_bucket_locations_api_import_csvs.aws_s3_bucket_policy.this
}

data "aws_iam_policy_document" "location_api_import_csvs" {
  statement {
    sid = "EKSNodesCanList"
    principals {
      type        = "AWS"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_arn]
    }
    actions   = ["s3:ListBucket"]
    resources = [local.secure_s3_bucket_locations_api_import_csvs_arn]
  }
  statement {
    sid = "EKSNodesCanWrite"
    principals {
      type        = "AWS"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_arn]
    }
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${local.secure_s3_bucket_locations_api_import_csvs_arn}/*"]
  }
}
