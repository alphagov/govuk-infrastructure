module "secure_s3_bucket_ai_accelerator_data" {
  source            = "../../shared-modules/s3"
  count             = var.enable_govuk_ai_accelerator ? 1 : 0
  govuk_environment = var.govuk_environment

  name = "govuk-ai-accelerator-data-${var.govuk_environment}"

}

moved {
  from = aws_s3_bucket.govuk_ai_accelerator_data[0].id
  to   = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket.this.id
}

moved {
  from = aws_s3_bucket_public_access_block.govuk_ai_accelerator_data_access_block[0].id
  to   = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket_public_access_block.this.id
}

moved {
  from = aws_s3_bucket_versioning.govuk_ai_accelerator_data_versioning[0].id
  to   = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket_versioning.this.id
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.govuk_ai_accelerator_data_encryption[0].id
  to   = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket_server_side_encryption_configuration.this.id
}

moved {
  from = aws_s3_bucket_policy.govuk_ai_accelerator_data_bucket_policy[0].id
  to   = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket_policy.this.id
}

moved {
  from = aws_s3_bucket_ownership_controls.govuk_ai_accelerator_data_owner_controls[0].id
  to   = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket_ownership_controls.this.id
}

moved {
  from = aws_s3_bucket_logging.govuk_ai_accelerator_data_logging[0].id
  to   = module.secure_s3_bucket_ai_accelerator_data[0].aws_s3_bucket_logging.this.id
}
