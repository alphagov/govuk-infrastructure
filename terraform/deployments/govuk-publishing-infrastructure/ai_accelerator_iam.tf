data "aws_iam_policy_document" "govuk_ai_accelerator_bedrock_access" {
  statement {
    sid = "BedrockAssumeInvokeModelsRolePolicy"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    effect    = "Allow"
    resources = ["arn:aws:bedrock:eu-west-1:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    sid = "BedrockAssumeListModelsRolePolicy"
    actions = [
      "bedrock:ListFoundationModels"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "govuk_ai_accelerator_s3_access" {
  statement {
    sid       = "GovukAiAcceleratorS3RootAccessPolicy"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [aws_s3_bucket.govuk_ai_accelerator_data[0].arn]
  }

  statement {
    sid = "GovukAiAcceleratorS3ObjectAccessPolicy"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["${aws_s3_bucket.govuk_ai_accelerator_data[0].arn}/*"]
  }
}