data "aws_iam_policy_document" "govuk_fastly_service_role_assume" {
  statement {
    sid     = "FastlyServiceRoleTrustPolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["717331877981"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.fastly_account_id]
    }
  }
}

resource "aws_iam_role" "govuk_fastly_service_role" {
  name = "govuk_fastly_service_role"

  assume_role_policy = data.aws_iam_policy_document.govuk_fastly_service_role_assume.json

  tags = {
    Name = "govuk_fastly_service_role"
    Type = "ServiceRole"
  }
}

data "aws_iam_policy_document" "govuk_fastly_s3_access" {
  statement {
    sid    = "S3AssumeRolePolicy"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload"
    ]
    resources = concat(
      [
        data.tfe_outputs.fastly_logs.nonsensitive_values.govuk_fastly_logs_s3_bucket_arn,
        "${data.tfe_outputs.fastly_logs.nonsensitive_values.govuk_fastly_logs_s3_bucket_arn}/*"
      ],
      var.govuk_environment == "production" ? [
        "arn:aws:s3:::govuk-analytics-logs-production",
        "arn:aws:s3:::govuk-analytics-logs-production/*"
      ] : []
    )
  }
}

resource "aws_iam_policy" "govuk_fastly_s3_access" {
  name   = "govuk-fastly-s3-access-policy"
  policy = data.aws_iam_policy_document.govuk_fastly_s3_access.json
}

resource "aws_iam_role_policy_attachment" "govuk_fastly_s3_access" {
  role       = aws_iam_role.govuk_fastly_service_role.name
  policy_arn = aws_iam_policy.govuk_fastly_s3_access.arn
}
