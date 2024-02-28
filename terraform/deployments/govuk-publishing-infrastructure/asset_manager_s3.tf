data "aws_iam_policy_document" "asset_manager_s3" {
  statement {
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [data.terraform_remote_state.infra_assets.outputs.asset_manager_bucket_arn]
  }

  statement {
    actions = [
      "s3:*MultipartUpload*",
      "s3:*Object",
      "s3:*ObjectAcl",
      "s3:*ObjectVersion",
      "s3:GetObject*Attributes"
    ]
    resources = ["${data.terraform_remote_state.infra_assets.outputs.asset_manager_bucket_arn}/*"]

  }
}

resource "aws_iam_policy" "asset_manager_s3" {
  name        = "asset_manager_s3"
  description = "Asset manager s3 policy"
  policy      = data.aws_iam_policy_document.asset_manager_s3.json
}

resource "aws_iam_role_policy_attachment" "asset_manager_s3" {
  role       = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.worker_iam_role_name
  policy_arn = aws_iam_policy.asset_manager_s3.arn
}
