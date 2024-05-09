resource "aws_s3_bucket" "search_relevancy_bucket" {
  bucket = "govuk-${var.govuk_environment}-search-relevancy"
}

resource "aws_s3_bucket_logging" "search_relevancy_bucket" {
  bucket = aws_s3_bucket.search_relevancy_bucket.id

  target_bucket = "govuk-${var.govuk_environment}-aws-logging"
  target_prefix = "s3/govuk-${var.govuk_environment}-search-relevancy/"
}

resource "aws_s3_bucket_lifecycle_configuration" "search_relevancy_bucket" {
  bucket = aws_s3_bucket.search_relevancy_bucket.id

  rule {
    id     = "expire_training_data"
    status = "Enabled"
    filter { prefix = "data/" }
    expiration { days = 7 }
  }

  rule {
    id     = "expire_models"
    status = "Enabled"
    filter { prefix = "model/" }
    expiration { days = 7 }
  }
}
