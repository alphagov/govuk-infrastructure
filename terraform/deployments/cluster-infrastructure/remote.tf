data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "tfe_outputs" "vpc" {
  organization = "govuk"
  workspace    = startswith(var.govuk_environment, "eph-") ? "vpc-ephemeral" : "vpc-${var.govuk_environment}"
}
