data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "infra_vpc" {
  backend = "s3"
  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "govuk/infra-vpc.tfstate"
    region = data.aws_region.current.name
  }
}

data "terraform_remote_state" "infra_root_dns_zones" {
  backend = "s3"
  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "govuk/infra-root-dns-zones.tfstate"
    region = data.aws_region.current.name
  }
}
