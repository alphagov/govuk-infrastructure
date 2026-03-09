module "secure_s3_bucket_csp_reports" {
  source = "github.com/alphagov/govuk-infrastructure/terraform/shared-modules/s3?ref=3f260111d76ce69eeb1f6b9b8d3ea52e1bd467b4"
  name   = "govuk-${var.govuk_environment}-csp-reports"

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
