resource "aws_s3_bucket" "location_api_import_csvs" {
  bucket        = "govuk-${var.govuk_environment}-locations-api-import-csvs"
  force_destroy = var.force_destroy
  tags = {
    System = "Locations API"
    Name   = "CSVs for importing postcode information into Locations API"
  }
}

resource "aws_s3_bucket_versioning" "location_api_import_csvs" {
  bucket = aws_s3_bucket.location_api_import_csvs.id
  versioning_configuration { status = "Suspended" }
}

resource "aws_s3_bucket_policy" "location_api_import_csvs" {
  bucket = aws_s3_bucket.location_api_import_csvs.id
  policy = data.aws_iam_policy_document.location_api_import_csvs.json
}

# TODO: instead of granting write access to nodes, use IRSA (IAM Roles for
# Service Accounts aka pod identity) so that only locations-api can write.
data "aws_iam_policy_document" "location_api_import_csvs" {
  statement {
    sid = "EKSNodesCanList"
    principals {
      type        = "AWS"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_arn]
    }
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.location_api_import_csvs.arn]
  }
  statement {
    sid = "EKSNodesCanWrite"
    principals {
      type        = "AWS"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_arn]
    }
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.location_api_import_csvs.arn}/*"]
  }
}
