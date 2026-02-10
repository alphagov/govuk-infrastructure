module "secure_s3_bucket" {
  source = "../../../../shared-modules/s3/"

  name                            = local.bucket_name
  AES256_encryption_configuration = true
  versioning_enabled              = true
  govuk_environment               = var.govuk_environment
  lifecycle_rules = [
    {
      id     = "delete-exec-audit-logs-after-a-year"
      status = "Enabled"
      filter = {}
      expiration = {
        days = 365
      }
      noncurrent_version_expiration = {
        noncurrent_days = 365
      }
    }
  ]
}

