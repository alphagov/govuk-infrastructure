data "terraform_remote_state" "infra_monitoring" {
  backend = "s3"

  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "${coalesce(var.remote_state_infra_monitoring_key_stack, var.stackname)}/infra-monitoring.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "infra_networking" {
  backend = "s3"

  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "${coalesce(var.remote_state_infra_networking_key_stack, var.stackname)}/infra-networking.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "infra_root_dns_zones" {
  backend = "s3"

  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "${coalesce(var.remote_state_infra_root_dns_zones_key_stack, var.stackname)}/infra-root-dns-zones.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "infra_vpc" {
  backend = "s3"

  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "${coalesce(var.remote_state_infra_vpc_key_stack, var.stackname)}/infra-vpc.tfstate"
    region = var.aws_region
  }
}
