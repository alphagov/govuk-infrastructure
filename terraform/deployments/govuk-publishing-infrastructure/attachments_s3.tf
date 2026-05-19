locals {
  lifecycle_rules_integration = [
    {
      id     = "Expire-30-Days"
      status = "Enabled"
      expiration = {
        days = 30
      }
    }
  ]
}

module "secure_s3_bucket_attachments" {
  source            = "../../shared-modules/s3"
  govuk_environment = var.govuk_environment

  name = "govuk-attachments-${var.govuk_environment}"

  enforce_bucket_object_ownership = false
  enable_public_access_block      = false
  lifecycle_rules                 = var.govuk_environment == "integration" ? local.lifecycle_rules_integration : null
  versioning_enabled              = var.govuk_environment == "production" ? true : false
}

resource "aws_s3_bucket_acl" "attachments" {
  bucket = module.secure_s3_bucket_attachments.name
  acl    = "private"
}

moved {
  from = aws_s3_bucket.attachments
  to   = module.secure_s3_bucket_attachments.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_versioning.attachments
  to   = module.secure_s3_bucket_attachments.aws_s3_bucket_versioning.this
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.attachments[0]
  to   = module.secure_s3_bucket_attachments.aws_s3_bucket_lifecycle_configuration.this[0]
}
