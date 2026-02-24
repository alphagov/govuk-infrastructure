data "tfe_outputs" "cluster_infrastructure" {
  organization = "govuk"
  workspace    = "cluster-infrastructure-${var.govuk_environment}"
}

data "tfe_outputs" "root_dns" {
  count        = contains(["integration", "staging", "production"], var.govuk_environment) ? 1 : 0
  organization = "govuk"
  workspace    = "root-dns-${var.govuk_environment}"
}

data "tfe_outputs" "vpc" {
  organization = "govuk"
  workspace    = "vpc-${var.govuk_environment}"
}

