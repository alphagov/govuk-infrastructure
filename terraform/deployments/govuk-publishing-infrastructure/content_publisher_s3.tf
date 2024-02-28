data "aws_iam_policy_document" "content_publisher_s3" {
  statement {
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [data.terraform_remote_state.infra_content_publisher.outputs.activestorage_s3_bucket_arn]
  }

  statement {
    actions = [
      "s3:*MultipartUpload*",
      "s3:*Object",
      "s3:*ObjectAcl",
      "s3:*ObjectVersion",
      "s3:GetObject*Attributes"
    ]
    resources = ["${data.terraform_remote_state.infra_content_publisher.outputs.activestorage_s3_bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "content_publisher_s3" {
  name        = "content_publisher_s3"
  description = "Read and write to this environment's content-publisher-activestorage bucket."

  policy = data.aws_iam_policy_document.content_publisher_s3.json
}

# TODO: consider IRSA (pod identity) rather than granting to nodes.
resource "aws_iam_role_policy_attachment" "content_publisher_s3" {
  role       = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_name
  policy_arn = aws_iam_policy.content_publisher_s3.arn
}
