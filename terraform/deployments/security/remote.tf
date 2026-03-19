data "aws_region" "current" {}

data "tfe_outputs" "cluster_infrastructure" {
  organization = "govuk"
  workspace    = "cluster-infrastructure-${var.govuk_environment}"
}

data "tfe_outputs" "vpc" {
  organization = "govuk"
  workspace    = "vpc-${var.govuk_environment}"
}

data "tfe_outputs" "fastly_logs" {
  organization = "govuk"
  workspace    = "govuk-fastly-logs-${var.govuk_environment}"
}
