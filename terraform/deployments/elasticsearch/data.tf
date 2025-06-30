data "aws_caller_identity" "current" {}
data "aws_region" "current" {
  name = var.aws_region
}
data "tfe_outputs" "cluster_infrastructure" {
  organization = "govuk"
  workspace    = "cluster-infrastructure-${var.govuk_environment}"
}

data "tfe_outputs" "security" {
  organization = "govuk"
  workspace    = "security-${var.govuk_environment}"
}

data "tfe_outputs" "vpc" {
  organization = "govuk"
  workspace    = "vpc-${var.govuk_environment}"
}

data "tfe_outputs" "root_dns" {
  organization = "govuk"
  workspace    = "root-dns-${var.govuk_environment}"
}

data "tfe_outputs" "logging" {
  organization = "govuk"
  workspace    = "logging-${var.govuk_environment}"
}

data "aws_acm_certificate" "govuk_internal" {
  domain   = "*.${var.govuk_environment}.govuk-internal.digital"
  statuses = ["ISSUED"]
}
