module "s3_bucket_chunks" {
  source = "../../shared-modules/s3"

  name              = "govuk-${var.govuk_environment}-loki-chunks"
  govuk_environment = var.govuk_environment

  disable_bucket_logging = true
}

module "s3_bucket_ruler" {
  source = "../../shared-modules/s3"

  name              = "govuk-${var.govuk_environment}-loki-ruler"
  govuk_environment = var.govuk_environment

  disable_bucket_logging = true
}
