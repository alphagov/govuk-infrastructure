resource "aws_iam_policy" "write_csvs_buckets" {
  name        = "csvs_s3"
  description = "Read and write to this environment's CSVS s3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
        ]
        Resource = [
          aws_s3_bucket.publisher_csvs.arn,
          "arn:aws:s3:::govuk-${var.govuk_environment}-content-data-csvs",
          "arn:aws:s3:::govuk-${var.govuk_environment}-specialist-publisher-csvs",
          "arn:aws:s3:::govuk-${var.govuk_environment}-support-api-csvs",
          "arn:aws:s3:::govuk-${var.govuk_environment}-whitehall-csvs"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:*MultipartUpload*",
          "s3:*Object",
          "s3:*ObjectAcl",
          "s3:*ObjectVersion",
          "s3:GetObject*Attributes",
        ]
        Resource = [
          "${aws_s3_bucket.publisher_csvs.arn}/*",
          "arn:aws:s3:::govuk-${var.govuk_environment}-content-data-csvs/*",
          "arn:aws:s3:::govuk-${var.govuk_environment}-specialist-publisher-csvs/*",
          "arn:aws:s3:::govuk-${var.govuk_environment}-support-api-csvs/*",
          "arn:aws:s3:::govuk-${var.govuk_environment}-whitehall-csvs/*"
        ]
      }
    ]
  })
}

# TODO: consider IRSA (pod identity) rather than granting to nodes.
resource "aws_iam_role_policy_attachment" "write_csvs_buckets" {
  role       = data.terraform_remote_state.cluster_infrastructure.outputs.worker_iam_role_name
  policy_arn = aws_iam_policy.write_csvs_buckets.arn
}
