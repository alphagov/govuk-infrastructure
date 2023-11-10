resource "aws_s3_bucket" "publisher_csvs" {
  bucket        = "govuk-${var.govuk_environment}-publisher-csvs"
  force_destroy = var.force_destroy
  tags = {
    Product     = "GOV.UK"
    System      = "Publisher"
    Environment = "${var.govuk_environment}"
    Owner       = "govuk-replatforming-team@digital.cabinet-office.gov.uk"
    Name        = "govuk-${var.env}-${var.region}-publisher-csvs"
  }
}
