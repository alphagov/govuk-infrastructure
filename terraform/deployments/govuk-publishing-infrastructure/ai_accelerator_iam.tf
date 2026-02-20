# IAM role for govuk-ai-accelerator application with access to Bedrock and S3

locals {
  govuk_ai_accelerator_service_account_name = "govuk-ai-accelerator-app"
}

data "aws_iam_policy_document" "govuk_ai_accelerator_bedrock_access" {
  count = var.enable_govuk_ai_accelerator ? 1 : 0

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
  count = var.enable_govuk_ai_accelerator ? 1 : 0

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

resource "aws_iam_policy" "govuk_ai_accelerator_s3_access_policy" {
  count = var.enable_govuk_ai_accelerator ? 1 : 0

  name        = "govuk-${var.govuk_environment}-govuk-ai-accelerator-s3-policy"
  description = "Policy for govuk-ai-accelerator application with access to S3"
  policy      = data.aws_iam_policy_document.govuk_ai_accelerator_s3_access[0].json
}

resource "aws_iam_policy" "govuk_ai_accelerator_bedrock_access_policy" {
  count = var.enable_govuk_ai_accelerator ? 1 : 0

  name        = "govuk-${var.govuk_environment}-govuk-ai-accelerator-bedrock-policy"
  description = "Policy for govuk-ai-accelerator application with access to bedrock"
  policy      = data.aws_iam_policy_document.govuk_ai_accelerator_bedrock_access[0].json
}

# IRSA role for GOVUK AI Accelerator service account
module "govuk_reports_iam_role" {
  count = var.enable_govuk_ai_accelerator ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  name                 = "${local.govuk_ai_accelerator_service_account_name}-${data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id}"
  use_name_prefix      = false
  description          = "Role for govuk-ai-accelerator application. Corresponds to ${local.govuk_ai_accelerator_service_account_name} k8s ServiceAccount."
  max_session_duration = 28800

  policies = {
    "${aws_iam_policy.govuk_ai_accelerator_s3_access_policy[0].name}"      = aws_iam_policy.govuk_ai_accelerator_s3_access_policy[0].arn,
    "${aws_iam_policy.govuk_ai_accelerator_bedrock_access_policy[0].name}" = aws_iam_policy.govuk_ai_accelerator_bedrock_access_policy[0].arn
  }

  oidc_providers = {
    main = {
      provider_arn               = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn
      namespace_service_accounts = ["apps:${local.govuk_ai_accelerator_service_account_name}"]
    }
  }
}
