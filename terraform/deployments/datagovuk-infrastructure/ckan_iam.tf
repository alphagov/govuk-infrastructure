
module "ckan_iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 5.0"
  create_role                   = true
  role_name                     = "${var.ckan_service_account_name}-${local.cluster_id}"
  role_description              = "Role for CKAN S3 access. Corresponds to ${var.ckan_service_account_namespace}/${var.ckan_service_account_name} k8s ServiceAccount."
  provider_url                  = local.oidc_provider
  role_policy_arns              = [aws_iam_policy.ckan.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.ckan_service_account_namespace}:${var.ckan_service_account_name}"]
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
