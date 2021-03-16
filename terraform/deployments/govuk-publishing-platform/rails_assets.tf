locals {
  workspace_transformation = terraform.workspace == "default" ? "ecs" : terraform.workspace
}

resource "aws_s3_bucket" "rails_assets" {
  bucket = "govuk-${var.govuk_environment}-${local.workspace_transformation}-rails-assets"

  tags = {
    name            = "govuk-${var.govuk_environment}-${local.workspace_transformation}-rails-assets"
    aws_environment = var.govuk_environment
  }
}

data "aws_iam_policy_document" "cloudfront_access_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.rails_assets.arn}/*"]

    principals {
      type = "AWS"
      identifiers = [
        module.www_origin.cloudfront_access_identity_iam_arn,
        module.draft_origin.cloudfront_access_identity_iam_arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_access_s3_policy" {
  bucket = aws_s3_bucket.rails_assets.id
  policy = data.aws_iam_policy_document.cloudfront_access_s3_policy.json
}
