module "govuk_mirror_sync_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "~> 5.28"

  role_name        = "govuk-mirror-sync"
  role_description = "Role for govuk-mirror-sync to access S3. Corresponds to govuk-mirror-sync k8s ServiceAccount."

  cluster_service_accounts = {
    "${local.cluster_name}" = ["apps:govuk-mirror-sync"]
  }

  role_policy_arns = {
    govuk_mirror_sync_policy = aws_iam_policy.govuk_mirror_sync.arn
  }
}

data "aws_iam_policy_document" "govuk_mirror_sync" {
  statement {
    sid = "ReadWriteFromS3"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:ListMultipartUploadParts",
      "s3:PutAccelerateConfiguration",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging"
    ]
    resources = [
      "arn:aws:s3:::govuk-${var.govuk_environment}-mirror/*",
      "arn:aws:s3:::govuk-${var.govuk_environment}-mirror"
    ]
  }
}

resource "aws_iam_policy" "govuk_mirror_sync" {
  name        = "govuk-mirror-sync"
  description = "Allows mirror sync process to access S3."

  policy = data.aws_iam_policy_document.govuk_mirror_sync.json
}
