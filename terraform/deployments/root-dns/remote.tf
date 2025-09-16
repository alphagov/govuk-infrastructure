data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "govuk-ah-test-state-files"
    key    = "vpc.tfstate"
  }
}

