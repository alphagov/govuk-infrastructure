resource "aws_s3_bucket" "backends_content_schema" {
  bucket = "govuk-${var.govuk_environment}-${local.workspace}-content-schema"

  # Unless we're in staging or production, it's okay to delete this bucket
  # even if it still contains objects.
  #
  # In the lower environments, we want to be able to run `terraform destroy`
  # without having to manually delete all the assets from the bucket.
  force_destroy = contains(["staging", "production"], var.govuk_environment) ? false : true

  tags = {
    name            = "govuk-${var.govuk_environment}-${local.workspace}-1-content-schema"
    aws_environment = var.govuk_environment
  }
}

resource "aws_s3_bucket_policy" "backends_cloudfront_access_s3_policy" {
  bucket = aws_s3_bucket.backends_content_schema.id
  policy = data.aws_iam_policy_document.backends_cloudfront_access_s3_policy.json
}
