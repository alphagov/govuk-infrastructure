data "tfe_outputs" "vpc" {
  organization = "govuk"
  workspace    = "vpc-${var.govuk_environment}"
}

data "tfe_outputs" "fastly_www" {
  organization = "govuk"
  workspace    = "govuk-fastly-www-${var.govuk_environment}"
}