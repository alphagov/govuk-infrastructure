data "aws_region" "current" {}

data "aws_caller_identity" "current" {}


data "tfe_outputs" "networking" {
  organization = "govuk"
  workspace    = "tools_networking"
}

