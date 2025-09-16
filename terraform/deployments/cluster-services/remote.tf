locals {
  env_suffix = startswith(var.govuk_environment, "eph-") ? "ephemeral" : "${var.govuk_environment}"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "cluster_infrastructure" {
  backend = "s3"
  config = {
    bucket = "govuk-ah-test-state-files"
    key    = "cluster-infrastructure.tfstate"
  }
}


data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "govuk-ah-test-state-files"
    key    = "vpc.tfstate"
  }
}
