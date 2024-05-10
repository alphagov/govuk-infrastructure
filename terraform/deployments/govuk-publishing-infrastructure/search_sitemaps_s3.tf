resource "aws_s3_bucket" "search_sitemaps_bucket" {
  bucket = "govuk-${var.govuk_environment}-sitemaps"
}

resource "aws_s3_bucket_logging" "search_sitemaps_bucket" {
  bucket        = aws_s3_bucket.search_sitemaps_bucket.id
  target_bucket = "govuk-${var.govuk_environment}-aws-logging"
  target_prefix = "s3/govuk-${var.govuk_environment}-sitemaps/"
}

resource "aws_s3_bucket_lifecycle_configuration" "search_sitemaps_bucket" {
  bucket = aws_s3_bucket.search_sitemaps_bucket.id

  rule {
    id     = "sitemaps_lifecycle_rule"
    status = "Enabled"
    expiration {
      days = 3
    }
  }
}
