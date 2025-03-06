locals {
  env_suffix = startswith(var.govuk_environment, "eph-") ? "ephemeral" : "${var.govuk_environment}"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "tfe_outputs" "cluster_infrastructure" {
  organization = "govuk"
  workspace    = "cluster-infrastructure-${var.govuk_environment}"
}

data "tfe_outputs" "vpc" {
  organization = "govuk"
  workspace    = startswith(var.govuk_environment, "eph-") ? "vpc-ephemeral" : "vpc-${var.govuk_environment}"
}
