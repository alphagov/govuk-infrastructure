data "tfe_outputs" "vpc" {
  organization = "govuk"
  workspace    = "vpc-${var.govuk_environment}"
}

data "tfe_outputs" "fastly_www" {
  # This is only needed in Production
  count = var.govuk_environment == "production" ? 1 : 0

  organization = "govuk"
  workspace    = "govuk-fastly-www-${var.govuk_environment}"
}