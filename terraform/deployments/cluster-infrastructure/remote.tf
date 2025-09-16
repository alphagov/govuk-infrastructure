data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "root_dns" {
  backend = "s3"
  config = {
    bucket = "govuk-ah-test-state-files"
    key    = "root-dns.tfstate"
  }
}


data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "govuk-ah-test-state-files"
    key    = "vpc.tfstate"
  }
}
