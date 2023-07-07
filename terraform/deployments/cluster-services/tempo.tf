locals {
  tempo_service_account = "tempo"
  cluster_name          = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_id
}

resource "aws_s3_bucket" "tempo" {
  bucket = "govuk-${var.govuk_environment}-tempo"
}

module "tempo_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "~> 5.27"

  role_name        = "${local.tempo_service_account}-${local.cluster_name}"
  role_description = "Role for Tempo to access AWS data sources. Corresponds to ${local.tempo_service_account} k8s ServiceAccount."
  role_policy_arns = {
    TempoPolicy = aws_iam_policy.tempo.arn
  }

  cluster_service_accounts = {
    "${local.cluster_name}" = ["${local.monitoring_ns}:${local.tempo_service_account}"]
  }
}

resource "aws_iam_policy" "tempo" {
  name        = "tempo-${local.cluster_name}"
  description = "Allows Tempo to access AWS data sources."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "TempoPermissions",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging"
        ],
        "Resource" : [
          "${aws_s3_bucket.tempo.arn}/*",
          "${aws_s3_bucket.tempo.arn}"
        ]
      }
    ]
  })
}

