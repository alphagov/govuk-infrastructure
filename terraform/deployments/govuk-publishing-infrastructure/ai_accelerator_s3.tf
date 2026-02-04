resource "aws_s3_bucket" "govuk_ai_accelerator_data" {
  bucket = "govuk-ai-accelerator-data-integration}"
}

resource "aws_s3_bucket_acl" "govuk_ai_accelerator_data" {
  bucket = aws_s3_bucket.govuk_ai_accelerator_data.id
  acl    = "private"
}

resource "aws_s3_bucket_logging" "govuk_ai_accelerator_data" {
  bucket        = aws_s3_bucket.govuk_ai_accelerator_data.id
  target_bucket = "govuk-integration-aws-logging"
  target_prefix = "s3/govuk-ai-accelerator-data-integration/"
}
