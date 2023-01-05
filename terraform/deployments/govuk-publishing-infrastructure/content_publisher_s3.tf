resource "aws_iam_policy" "content_publisher_s3" {
  name        = "content_publisher_s3"
  description = "Read and write to this environment's content-publisher-activestorage bucket."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
        ]
        Resource = data.terraform_remote_state.infra_content_publisher.outputs.activestorage_s3_bucket_arn
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
        Resource = "${data.terraform_remote_state.infra_content_publisher.outputs.activestorage_s3_bucket_arn}/*"
      }
    ]
  })
}

# TODO: consider IRSA (pod identity) rather than granting to nodes.
resource "aws_iam_role_policy_attachment" "content_publisher_s3" {
  role       = data.terraform_remote_state.cluster_infrastructure.outputs.worker_iam_role_name
  policy_arn = aws_iam_policy.content_publisher_s3.arn
}
