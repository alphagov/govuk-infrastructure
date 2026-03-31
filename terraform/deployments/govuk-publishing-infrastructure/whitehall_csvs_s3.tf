module "secure_s3_bucket_whitehall_csvs" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = "govuk-${var.govuk_environment}-whitehall-csvs"

  versioning_enabled = false
}
