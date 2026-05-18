locals {
  tempo_service_account = "tempo"
  cluster_name          = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id
  provider_arn          = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn
}

module "secure_s3_bucket_tempo" {
  source            = "../../shared-modules/s3"
  govuk_environment = var.govuk_environment

  name               = "govuk-${var.govuk_environment}-tempo"
  force_destroy      = true
  versioning_enabled = false
}

moved {
  from = aws_s3_bucket.tempo
  to   = module.secure_s3_bucket_tempo.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_policy.tempo_bucket_policy
  to   = module.secure_s3_bucket_tempo.aws_s3_bucket_policy.bucket_policy
}

module "tempo_iam_role" {
  depends_on = [module.secure_s3_bucket_tempo]

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  name            = "${local.tempo_service_account}-${local.cluster_name}"
  use_name_prefix = false
  description     = "Role for Tempo to access AWS data sources. Corresponds to ${local.tempo_service_account} k8s ServiceAccount."
  policies        = { TempoPolicy = aws_iam_policy.tempo.arn }

  oidc_providers = {
    "${local.cluster_name}" = {
      provider_arn               = local.provider_arn
      namespace_service_accounts = ["${local.monitoring_ns}:${local.tempo_service_account}"]
    }
  }
}

data "aws_iam_policy_document" "tempo" {
  statement {
    sid       = "TempoAccessDataSources"
    actions   = ["s3:ListBucket", "s3:?*Object", "s3:?*ObjectTagging"]
    resources = ["${module.secure_s3_bucket_tempo.arn}", "${module.secure_s3_bucket_tempo.arn}/*"]
  }
}

resource "aws_iam_policy" "tempo" {
  depends_on = [module.secure_s3_bucket_tempo]

  name        = "tempo-${local.cluster_name}"
  description = "Allows Tempo to access AWS data sources."
  policy      = data.aws_iam_policy_document.tempo.json
}
