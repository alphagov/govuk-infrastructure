data "aws_caller_identity" "current" {}
data "aws_region" "current" {
  name = var.aws_region
}
data "tfe_outputs" "cluster_infrastructure" {
  organization = "govuk"
  workspace    = "cluster-infrastructure-${var.govuk_environment}"
}
data "terraform_remote_state" "infra_vpc" {
  backend = "s3"
  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "govuk/infra-vpc.tfstate"
    region = data.aws_region.current.name
  }
}
data "terraform_remote_state" "infra_security_groups" {
  backend = "s3"
  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "govuk/infra-security-groups.tfstate"
    region = data.aws_region.current.name
  }
}

data "terraform_remote_state" "infra_root_dns_zones" {
  backend = "s3"
  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "govuk/infra-root-dns-zones.tfstate"
    region = var.aws_region
  }
}
data "terraform_remote_state" "infra_networking" {
  backend = "s3"
  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "govuk/infra-networking.tfstate"
    region = var.aws_region
  }
}
