locals {
  s3_bucket_datagovuk_bucket_name = "govuk-ckan-output-${var.govuk_environment}"
  s3_bucket_datagovuk_bucket_arn  = "arn:aws:s3:::${local.s3_bucket_datagovuk_bucket_name}"
}

module "s3_bucket_datagovuk_bucket" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = local.s3_bucket_datagovuk_bucket_name

  versioning_enabled   = true
  versioning_suspended = true

  enable_public_access_block = true
  extra_bucket_policies      = [data.aws_iam_policy_document.datagovuk_bucket.json]

  tags = {
    System = "Data.gov.uk CKAN outputs"
    Name   = "CKAN Output Bucket for ${var.govuk_environment}"
  }
}

# TODO: instead of granting write access to nodes, use IRSA (IAM Roles for
# Service Accounts aka pod identity) so that only Argo CD can write.
data "aws_iam_policy_document" "datagovuk_bucket" {
  statement {
    sid = "EKSNodesCanList"
    principals {
      type        = "AWS"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_arn]
    }
    actions   = ["s3:ListBucket"]
    resources = [local.s3_bucket_datagovuk_bucket_arn]
  }
  statement {
    sid = "EKSNodesCanWrite"
    principals {
      type        = "AWS"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_arn]
    }
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${local.s3_bucket_datagovuk_bucket_arn}/*"]
  }
}
