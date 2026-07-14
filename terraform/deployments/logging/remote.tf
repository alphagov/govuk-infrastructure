data "tfe_outputs" "vpc" {
  count = var.create_vpc_flow_logs ? 1 : 0

  organization = "govuk"
  workspace    = "vpc-${var.govuk_environment}"
}
