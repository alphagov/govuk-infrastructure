module "secure_s3_bucket_csp_reports" {
  source = "../../shared-modules/s3"

  govuk_environment = var.govuk_environment
  name              = "govuk-${var.govuk_environment}-csp-reports"

  versioning_enabled = false
  lifecycle_rules = [
    {
      id     = "govuk-${var.govuk_environment}-csp-reports-lifecycle"
      status = "Enabled"
      expiration = {
        days = 30
      }
    }
  ]
}

moved {
  from = aws_s3_bucket.csp_reports
  to   = module.secure_s3_bucket_csp_reports.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.csp_reports_lifecycle
  to   = module.secure_s3_bucket_csp_reports.aws_s3_bucket_lifecycle_configuration.this[0]
}

moved {
  from = aws_s3_bucket_policy.csp_reports
  to   = module.secure_s3_bucket_csp_reports.aws_s3_bucket_policy.bucket_policy
}
