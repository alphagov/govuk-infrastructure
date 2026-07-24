module "athena_query_results" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = "govuk-${var.govuk_environment}-athena-query-results"

  versioning_enabled         = false
  enable_public_access_block = true

  ownership_controls = {
    rules = [
      {
        object_ownership = "ObjectWriter"
      },
    ]
  }

  lifecycle_rules = [
    {
      id     = "govuk-${var.govuk_environment}-csp-reports-lifecycle"
      status = "Enabled"

      expiration = {
        days = 7
      }
    }
  ]
}

moved {
  from = aws_s3_bucket.athena_query_results
  to   = module.athena_query_results.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.athena_query_results
  to   = module.athena_query_results.aws_s3_bucket_lifecycle_configuration.this[0]
}
