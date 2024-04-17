resource "aws_s3_bucket" "athena_query_results" {
  bucket = "govuk-${var.govuk_environment}-athena-query-results"
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_query_results" {
  bucket = aws_s3_bucket.athena_query_results.id

  rule {
    id     = "govuk-${var.govuk_environment}-csp-reports-lifecycle"
    status = "Enabled"

    expiration {
      days = 7
    }
  }
}
