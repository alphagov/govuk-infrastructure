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
  source                       = "../../modules/govuk"
  vpc_id                       = "vpc-9e62bcf8"                                            # TODO: hardcoded
  private_subnets              = ["subnet-6dc4370b", "subnet-463bfd0e", "subnet-bfecd0e4"] # TODO: hardcoded
  public_subnets               = ["subnet-6cc4370a", "subnet-ba30f6f2", "subnet-bfe6dae4"] # TODO: hardcoded
  govuk_app_domain_external    = "test.govuk.digital"
  govuk_website_root           = "test.publishing.service.gov.uk"
  mongodb_host                 = "mongo-1.test.govuk-internal.digital,mongo-2.test.govuk-internal.digital,mongo-3.test.govuk-internal.digital"
  statsd_host                  = "statsd.test.govuk-internal.digital"
  documentdb_security_group_id = "sg-08a20d332cbc59c3c"
  redis_security_group_id      = "sg-0a8a92451bfde8aa3"
}
