data "aws_iam_policy_document" "transition_s3" {
  statement {
    actions   = ["s3:GetBucketLocation", "s3:GetObject", "s3:ListBucket"]
    resources = ["arn:aws:s3:::govuk-${var.govuk_environment}-transition-fastly-logs*"]
  }
}

resource "aws_iam_policy" "transition_s3" {
  name        = "transition_s3"
  description = "Read processed CDN request logs for redirects from legacy domains."
  policy      = data.aws_iam_policy_document.transition_s3.json
}

# TODO: consider IRSA (pod identity) rather than granting to nodes.
resource "aws_iam_role_policy_attachment" "transition_s3" {
  role       = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_name
  policy_arn = aws_iam_policy.transition_s3.arn
}
