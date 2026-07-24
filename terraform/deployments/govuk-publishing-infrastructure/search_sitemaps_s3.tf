module "search_sitemaps_bucket" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = "govuk-${var.govuk_environment}-sitemaps"

  versioning_enabled         = false
  enable_public_access_block = false

  disable_bucket_logging = startswith(var.govuk_environment, "eph-") ? true : false
  access_logging_config = {
    target_bucket = "govuk-${var.govuk_environment}-aws-logging"
    target_prefix = "s3/govuk-${var.govuk_environment}-sitemaps/"
  }

  ownership_controls = {
    rules = [
      {
        object_ownership = "ObjectWriter"
      },
    ]
  }

  lifecycle_rules = [
    {
      id     = "sitemaps_lifecycle_rule"
      status = "Enabled"

      expiration = {
        days = 3
      }
    }
  ]
}

moved {
  from = aws_s3_bucket.search_sitemaps_bucket
  to   = module.search_sitemaps_bucket.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.search_sitemaps_bucket
  to   = module.search_sitemaps_bucket.aws_s3_bucket_lifecycle_configuration.this[0]
}

moved {
  from = aws_s3_bucket_logging.search_sitemaps_bucket
  to   = module.search_sitemaps_bucket.aws_s3_bucket_logging.this[0]
}
