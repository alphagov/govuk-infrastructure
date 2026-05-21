module "secure_s3_bucket_ai_accelerator_data" {
  source            = "../../shared-modules/s3"
  count             = var.enable_govuk_ai_accelerator ? 1 : 0
  govuk_environment = var.govuk_environment

  name = "govuk-ai-accelerator-data-${var.govuk_environment}"

}
