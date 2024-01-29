data "aws_iam_policy_document" "publishing_api_s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]
    # These buckets don't seem to be defined in alphagov/govuk-aws.
    resources = ["arn:aws:s3:::govuk-publishing-api-event-log-${var.govuk_environment}"]
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
    resources = ["arn:aws:s3:::govuk-publishing-api-event-log-${var.govuk_environment}/*"]
  }
}

resource "aws_iam_policy" "publishing_api_s3" {
  name        = "publishing_api_s3"
  description = "Read and write govuk-publishing-api-event-log-${var.govuk_environment} bucket."
  policy      = data.aws_iam_policy_document.publishing_api_s3.json
}

# TODO: consider IRSA (pod identity) rather than granting to nodes.
resource "aws_iam_role_policy_attachment" "publishing_api_s3" {
  role       = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_name
  policy_arn = aws_iam_policy.publishing_api_s3.arn
}
