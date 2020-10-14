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

data "aws_security_group" "documentdb" {
  name = "govuk_shared_documentdb_access"
}

data "aws_security_group" "govuk_management_access" {
  name = "govuk_management_access"
}

data "aws_security_group" "redis" {
  name = "govuk_backend-redis_access"
}

module "govuk" {
  source                        = "../../modules/govuk"
  vpc_id                        = "vpc-9e62bcf8"                                            # TODO: hardcoded
  private_subnets               = ["subnet-6dc4370b", "subnet-463bfd0e", "subnet-bfecd0e4"] # TODO: hardcoded
  public_subnets                = ["subnet-6cc4370a", "subnet-ba30f6f2", "subnet-bfe6dae4"] # TODO: hardcoded
  public_lb_domain_name         = "test.govuk.digital"
  govuk_app_domain_external     = "test.govuk.digital"
  govuk_app_domain_internal     = "test.govuk-internal.digital"
  govuk_website_root            = "test.publishing.service.gov.uk"
  asset_host                    = "www.gov.uk" # TODO: this looks wrong
  mongodb_host                  = "mongo-1.test.govuk-internal.digital,mongo-2.test.govuk-internal.digital,mongo-3.test.govuk-internal.digital"
  redis_host                    = "pink-backend-redis.0f3erf.ng.0001.euw1.cache.amazonaws.com"
  statsd_host                   = "statsd.test.govuk-internal.digital"
  govuk_management_access_sg_id = data.aws_security_group.govuk_management_access.id
  documentdb_security_group_id  = data.aws_security_group.documentdb.id
  redis_security_group_id       = data.aws_security_group.redis.id
}
