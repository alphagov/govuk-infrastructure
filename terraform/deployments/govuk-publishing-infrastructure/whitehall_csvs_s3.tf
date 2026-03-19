module "secure_s3_bucket_whitehall_csvs" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = "govuk-${var.govuk_environment}-whitehall-csvs"

  versioning_enabled = false
}

moved {
  from = aws_s3_bucket.whitehall_csvs
  to   = module.secure_s3_bucket_whitehall_csvs.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_logging.whitehall_csvs
  to   = module.secure_s3_bucket_whitehall_csvs.aws_s3_bucket_logging.this
}
