resource "aws_iam_role" "loki" {
  name = "loki-${var.govuk_environment}"

  assume_role_policy = data.aws_iam_policy_document.loki_assume_role.json
}

data "aws_iam_policy_document" "loki_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider}:sub"
      values   = ["system:serviceaccount:loki:loki"]
    }

    condition {
      test     = "StringEquals"
      variable = "${data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "loki" {
  name   = "LokiReadWriteBucket"
  role   = aws_iam_role.loki.id
  policy = data.aws_iam_policy_document.loki.json
}

data "aws_iam_policy_document" "loki" {
  statement {
    sid = "LokiListBucket"

    actions = ["s3:ListBucket"]

    resources = [
      module.s3_bucket_chunks.arn,
      module.s3_bucket_ruler.arn,
    ]
  }

  statement {
    sid = "LokiWriteToBucket"

    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${module.s3_bucket_chunks.arn}/*",
      "${module.s3_bucket_ruler.arn}/*",
    ]
  }
}
