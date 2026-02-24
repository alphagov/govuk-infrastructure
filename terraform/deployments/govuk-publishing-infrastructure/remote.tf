data "aws_region" "current" {}

data "tfe_outputs" "cluster_infrastructure" {
  organization = "govuk"
  workspace    = "cluster-infrastructure-${var.govuk_environment}"
}

data "tfe_outputs" "rds" {
  organization = "govuk"
  workspace    = "rds-${var.govuk_environment}"
}

data "tfe_outputs" "neptune" {
  count        = var.enable_govuk_ai_accelerator ? 1 : 0
  organization = "govuk"
  workspace    = "neptune-${var.govuk_environment}"
}

data "tfe_outputs" "root_dns" {
  organization = "govuk"
  workspace    = "root-dns-${var.govuk_environment}"
}

data "tfe_outputs" "vpc" {
  organization = "govuk"
  workspace    = "vpc-${var.govuk_environment}"
}

data "tfe_outputs" "security" {
  organization = "govuk"
  workspace    = "security-${var.govuk_environment}"
}

data "tfe_outputs" "fastly_logs" {
  organization = "govuk"
  workspace    = "govuk-fastly-logs-${var.govuk_environment}"
}


data "fastly_ip_ranges" "fastly" {}
