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

data "aws_nat_gateway" "govuk" {
  count     = length(local.public_subnets)
  subnet_id = local.public_subnets[count.index]
}

locals {
  nat_gateway_public_cidrs_list = [
    for nat_gateway in data.aws_nat_gateway.govuk :
    "${nat_gateway.public_ip}/32"
  ]
}
