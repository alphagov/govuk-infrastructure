
module "ckan_iam_role" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "~> 6.0"
  name               = "${var.ckan_service_account_name}-${local.cluster_id}"
  use_name_prefix    = false
  description        = "Role for CKAN S3 access. Corresponds to ${var.ckan_service_account_namespace}/${var.ckan_service_account_name} k8s ServiceAccount."
  enable_oidc        = true
  oidc_provider_urls = [local.oidc_provider]
  policies = {
    "${aws_iam_policy.ckan.name}" = aws_iam_policy.ckan.arn
  }
  oidc_subjects = ["system:serviceaccount:${var.ckan_service_account_namespace}:${var.ckan_service_account_name}"]
}

resource "aws_iam_policy" "ckan" {
  name        = "EKS-CKAN-${local.cluster_id}"
  description = "EKS ${var.ckan_service_account_name} policy for cluster ${local.cluster_id}"
  policy      = data.aws_iam_policy_document.ckan.json
}

data "aws_iam_policy_document" "ckan" {
  statement {
    sid     = "ckanS3Access"
    effect  = "Allow"
    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.datagovuk-organogram.arn,
      "${aws_s3_bucket.datagovuk-organogram.arn}/*"
    ]
  }
}

moved {
  from = module.ckan_iam_role.aws_iam_role_policy_attachment.custom[0]
  to   = module.ckan_iam_role.aws_iam_role_policy_attachment.this["EKS-CKAN-govuk"]
}
