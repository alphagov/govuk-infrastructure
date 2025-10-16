locals {
  tempo_service_account = "tempo"
  cluster_name          = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id
  provider_arn          = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn
}

resource "aws_s3_bucket" "tempo" {
  bucket = "govuk-${var.govuk_environment}-tempo"

  force_destroy = var.force_destroy
}

module "tempo_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  name        = "${local.tempo_service_account}-${local.cluster_name}"
  description = "Role for Tempo to access AWS data sources. Corresponds to ${local.tempo_service_account} k8s ServiceAccount."
  policies    = { TempoPolicy = aws_iam_policy.tempo.arn }

  oidc_providers = {
    "${local.cluster_name}" = {
      provider_arn               = local.provider_arn
      namespace_service_accounts = ["${local.monitoring_ns}:${local.tempo_service_account}"]
    }
  }
}

data "aws_iam_policy_document" "tempo" {
  statement {
    actions   = ["s3:ListBucket", "s3:?*Object", "s3:?*ObjectTagging"]
    resources = [aws_s3_bucket.tempo.arn, "${aws_s3_bucket.tempo.arn}/*"]
  }
}

resource "aws_iam_policy" "tempo" {
  name        = "tempo-${local.cluster_name}"
  description = "Allows Tempo to access AWS data sources."
  policy      = data.aws_iam_policy_document.tempo.json
}
