terraform {
  backend "s3" {
    bucket = "govuk-ah-test-state-files"
    key    = "root-dns.tfstate"
  }
}
