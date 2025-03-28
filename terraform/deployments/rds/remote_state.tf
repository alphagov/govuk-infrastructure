data "tfe_outputs" "cluster_infrastructure" {
  organization = "govuk"
  workspace    = "cluster-infrastructure-${var.govuk_environment}"
}

data "tfe_outputs" "logging" {
  organization = "govuk"
  workspace    = "logging-${var.govuk_environment}"
}

data "tfe_outputs" "vpc" {
  organization = "govuk"
  workspace    = "vpc-${var.govuk_environment}"
}
