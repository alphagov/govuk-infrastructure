data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "tfe_outputs" "cluster_infrastructure" {
  organization = "govuk"
  workspace    = "tools-cluster-infrastructure"
}

data "tfe_outputs" "networking" {
  organization = "govuk"
  workspace    = "tools_networking"
}


