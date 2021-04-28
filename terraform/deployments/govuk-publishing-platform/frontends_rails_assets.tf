resource "aws_s3_bucket" "frontends_rails_assets" {
  bucket = "govuk-${var.govuk_environment}-${local.workspace}-frontends-rails-assets"

  # Unless we're in staging or production, it's okay to delete this bucket
  # even if it still contains objects.
  #
  # In the lower environments, we want to be able to run `terraform destroy`
  # without having to manually delete all the assets from the bucket.
  force_destroy = contains(["staging", "production"], var.govuk_environment) ? false : true

  tags = {
    name            = "govuk-${var.govuk_environment}-${local.workspace}-frontends-rails-assets"
    aws_environment = var.govuk_environment
  }
}

data "aws_iam_policy_document" "frontends_cloudfront_access_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontends_rails_assets.arn}/*"]

    principals {
      type = "AWS"
      identifiers = [
        module.www_frontends_origin.cloudfront_access_identity_iam_arn,
        module.draft_frontends_origin.cloudfront_access_identity_iam_arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "frontends_cloudfront_access_s3_policy" {
  bucket = aws_s3_bucket.frontends_rails_assets.id
  policy = data.aws_iam_policy_document.frontends_cloudfront_access_s3_policy.json
}
