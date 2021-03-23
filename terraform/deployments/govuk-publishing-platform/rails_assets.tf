resource "aws_s3_bucket" "rails_assets" {
  bucket = "govuk-${var.govuk_environment}-${local.workspace}-rails-assets"

  tags = {
    name            = "govuk-${var.govuk_environment}-${local.workspace}-rails-assets"
    aws_environment = var.govuk_environment
  }
}
