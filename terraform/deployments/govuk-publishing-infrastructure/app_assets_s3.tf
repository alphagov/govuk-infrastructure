resource "aws_s3_bucket" "app_assets" {
  bucket        = "govuk-app-assets-${var.govuk_environment}"
  force_destroy = true
  tags = {
    Name        = "App static assets for ${var.govuk_environment}"
    Environment = var.govuk_environment
  }
}

resource "aws_s3_bucket_versioning" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id
  versioning_configuration { status = "Suspended" }
}

resource "aws_s3_bucket_policy" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id
  policy = data.aws_iam_policy_document.app_assets.json
}

# TODO: instead of granting write access to nodes, use IRSA (IAM Roles for
# Service Accounts aka pod identity) so that only ArgoCD can write.
data "aws_iam_policy_document" "app_assets" {
  statement {
    sid = "PublicCanReadButNotList"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.app_assets.arn}/*"]
  }
  statement {
    sid = "EKSNodesCanList"
    principals {
      type        = "AWS"
      identifiers = [data.terraform_remote_state.cluster_infrastructure.outputs.worker_iam_role_arn]
    }
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.app_assets.arn]
  }
  statement {
    sid = "EKSNodesCanWrite"
    principals {
      type        = "AWS"
      identifiers = [data.terraform_remote_state.cluster_infrastructure.outputs.worker_iam_role_arn]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.app_assets.arn}/*"]
  }
}
