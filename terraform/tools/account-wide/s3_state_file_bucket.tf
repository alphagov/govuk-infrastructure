module "state_file_bucket" {
  source = "../../shared-modules/s3"
  name   = "govuk-tools-state-files"

  govuk_environment = var.govuk_account

  depends_on = [module.logging_bucket]
}