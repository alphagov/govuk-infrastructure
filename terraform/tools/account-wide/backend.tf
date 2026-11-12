terraform {
  backend "s3" {
    bucket              = "govuk-tools-state-files"
    key                 = "terraform/tools/account-wide.tfstate"
    region              = "eu-west-1"
    allowed_account_ids = ["900804735337"]
    use_lockfile        = true
    encrypt             = true
  }
}


