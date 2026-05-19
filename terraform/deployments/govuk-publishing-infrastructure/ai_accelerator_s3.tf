module "secure_s3_bucket_ai_accelerator_data" {
  source            = "../../shared-modules/s3"
  count             = var.enable_govuk_ai_accelerator ? 1 : 0
  govuk_environment = var.govuk_environment

  name = "govuk-ai-accelerator-data-${var.govuk_environment}"

}

moved {
  from = aws_s3_bucket.govuk_ai_accelerator_data[0]
  to   = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_public_access_block.govuk_ai_accelerator_data_access_block[0]
  to   = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket_public_access_block.this[0]
}

moved {
  from = aws_s3_bucket_versioning.govuk_ai_accelerator_data_versioning[0]
  to   = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket_versioning.this
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.govuk_ai_accelerator_data_encryption[0]
  to   = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket_server_side_encryption_configuration.this
}

moved {
  from = aws_s3_bucket_policy.govuk_ai_accelerator_data_bucket_policy[0]
  to   = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket_policy.bucket_policy
}

moved {
  from = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket_ownership_controls.owner
  to   = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket_ownership_controls.owner[0]
}

moved {
  from = aws_s3_bucket_logging.govuk_ai_accelerator_data_logging[0]
  to   = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket_logging.this
}
