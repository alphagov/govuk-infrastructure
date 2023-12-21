resource "aws_iam_policy" "transition_s3" {
  name        = "transition_s3"
  description = "Read the processed CDN request logs for transitioned site redirects."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
        ]
        Resource = "arn:aws:s3:::govuk-${var.govuk_environment}-transition-fastly-logs*"
      }
    ]
  })
}

# TODO: consider IRSA (pod identity) rather than granting to nodes.
resource "aws_iam_role_policy_attachment" "transition_s3" {
  role       = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_name
  policy_arn = aws_iam_policy.transition_s3.arn
}
