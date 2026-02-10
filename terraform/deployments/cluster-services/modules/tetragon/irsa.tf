data "aws_iam_policy_document" "bucket_write_role_permissions" {
  statement {
    sid = "AllowFluenBitToPush"

    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}",
      "arn:aws:s3:::${local.bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "fluent_bit" {
  name        = "govuk-${var.govuk_environment}-fluent-bit-push-to-s3"
  description = "Allow fluent bit to push logs to S3"
  policy      = data.aws_iam_policy_document.bucket_write_role_permissions.json
}


module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  name                 = "${var.cluster_id}-fluent-bit-to-s3"
  use_name_prefix      = false
  description          = "Role for fluent-bit to push logs to s3. Corresponds to ${local.sa_name} k8s ServiceAccount."
  max_session_duration = 28800
  policies = {
    s3 = aws_iam_policy.fluent_bit.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.provider_arn
      namespace_service_accounts = ["${local.logging_namespace}:${local.sa_name}"]
    }
  }
}
