data "aws_iam_policy_document" "write_csvs_buckets" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.publisher_csvs.arn,
      "arn:aws:s3:::govuk-${var.govuk_environment}-content-data-csvs",
      "arn:aws:s3:::govuk-${var.govuk_environment}-content-data-siteimprove-sitemaps",
      "arn:aws:s3:::govuk-${var.govuk_environment}-specialist-publisher-csvs",
      "arn:aws:s3:::govuk-${var.govuk_environment}-support-api-csvs",
      "arn:aws:s3:::govuk-${var.govuk_environment}-whitehall-csvs"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:*MultipartUpload*",
      "s3:*Object",
      "s3:*ObjectAcl",
      "s3:*ObjectVersion",
      "s3:GetObject*Attributes"
    ]
    resources = [
      "${aws_s3_bucket.publisher_csvs.arn}/*",
      "arn:aws:s3:::govuk-${var.govuk_environment}-content-data-csvs/*",
      "arn:aws:s3:::govuk-${var.govuk_environment}-content-data-siteimprove-sitemaps/*",
      "arn:aws:s3:::govuk-${var.govuk_environment}-specialist-publisher-csvs/*",
      "arn:aws:s3:::govuk-${var.govuk_environment}-support-api-csvs/*",
      "arn:aws:s3:::govuk-${var.govuk_environment}-whitehall-csvs/*"
    ]
  }
}

resource "aws_iam_policy" "write_csvs_buckets" {
  name        = "csvs_s3"
  description = "Read and write to this environment's CSVS s3 buckets"
  policy      = data.aws_iam_policy_document.write_csvs_buckets.json
}

# TODO: consider IRSA (pod identity) rather than granting to nodes.
resource "aws_iam_role_policy_attachment" "write_csvs_buckets" {
  role       = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_name
  policy_arn = aws_iam_policy.write_csvs_buckets.arn
}
