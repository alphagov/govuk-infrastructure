module "licensing_application_forms_backup_s3_bucket" {
  source = "../../shared-modules/s3"

  name              = "govuk-licensing-application-forms-backup-${var.govuk_environment}"
  govuk_environment = var.govuk_environment
}
