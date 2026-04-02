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
