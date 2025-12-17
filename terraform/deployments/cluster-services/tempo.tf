locals {
  tempo_service_account = "tempo"
  cluster_name          = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id
}

resource "aws_s3_bucket" "tempo" {
  bucket = "govuk-${var.govuk_environment}-tempo"

  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_policy" "tempo_bucket_policy" {
  bucket = aws_s3_bucket.tempo.id
  policy = data.aws_iam_policy_document.tempo_bucket_policy.json
}

data "aws_iam_policy_document" "tempo_bucket_policy" {
  statement {
    sid    = "DenyNonTLS"
    effect = "Deny"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.tempo.arn}/*"]
    condition {
      test     = "Bool"
      values   = [false]
      variable = "aws:SecureTransport"
    }
  }
}

module "tempo_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "~> 5.27"

  role_name        = "${local.tempo_service_account}-${local.cluster_name}"
  role_description = "Role for Tempo to access AWS data sources. Corresponds to ${local.tempo_service_account} k8s ServiceAccount."
  role_policy_arns = { TempoPolicy = aws_iam_policy.tempo.arn }

  cluster_service_accounts = {
    "${local.cluster_name}" = ["${local.monitoring_ns}:${local.tempo_service_account}"]
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
