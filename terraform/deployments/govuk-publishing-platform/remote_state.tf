data "terraform_remote_state" "govuk_aws_mongo" {
  backend = "s3"
  config = {
    bucket   = var.govuk_aws_state_bucket
    key      = "${var.govuk_environment == "test" ? "pink" : "blue"}/app-mongo.tfstate"
    region   = data.aws_region.current.name
    role_arn = var.assume_role_arn
  }
}

data "terraform_remote_state" "govuk_aws_router_mongo" {
  backend = "s3"
  config = {
    bucket   = var.govuk_aws_state_bucket
    key      = "${var.govuk_environment == "test" ? "pink" : "blue"}/app-router-backend.tfstate"
    region   = data.aws_region.current.name
    role_arn = var.assume_role_arn
  }
}

data "terraform_remote_state" "infra_networking" {
  backend = "s3"
  config = {
    bucket   = var.govuk_aws_state_bucket
    key      = "govuk/infra-networking.tfstate"
    region   = data.aws_region.current.name
    role_arn = var.assume_role_arn
  }
}

data "terraform_remote_state" "infra_security_groups" {
  backend = "s3"
  config = {
    bucket   = var.govuk_aws_state_bucket
    key      = "govuk/infra-security-groups.tfstate"
    region   = data.aws_region.current.name
    role_arn = var.assume_role_arn
  }
}

data "fastly_ip_ranges" "fastly" {}

locals {
  aws_nat_gateways_cidrs = [
    for public_ip in data.terraform_remote_state.infra_networking.outputs.nat_gateway_elastic_ips_list :
    "${public_ip}/32"
  ]
}
