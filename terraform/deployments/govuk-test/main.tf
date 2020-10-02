terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/govuk.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "govuk" {
  source                    = "../../modules/govuk"
  vpc_id                    = "vpc-9e62bcf8" # TODO: hardcoded
  govuk_app_domain_external = "test.govuk.digital"
  govuk_website_root        = "test.publishing.service.gov.uk"
  mongodb_hostname          = "mongo-1.test.govuk-internal.digital,mongo-2.test.govuk-internal.digital,mongo-3.test.govuk-internal.digital"
}
