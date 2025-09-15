terraform {
  backend "s3" {
    bucket = "govuk-ah-test-state-files"
    key    = "vpc.tfstate"
  }
}
