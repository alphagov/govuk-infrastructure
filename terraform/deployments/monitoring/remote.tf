data "aws_region" "current" {}

data "terraform_remote_state" "cluster_infrastructure" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket = var.cluster_infrastructure_state_bucket
    key    = "projects/cluster-infrastructure.tfstate"
    region = data.aws_region.current.name
  }
}

data "terraform_remote_state" "infra_networking" {
  backend = "s3"
  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "govuk/infra-networking.tfstate"
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

data "terraform_remote_state" "infra_security_groups" {
  backend = "s3"
  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "govuk/infra-security-groups.tfstate"
    region = data.aws_region.current.name
  }
}

data "terraform_remote_state" "infra_vpc" {
  backend = "s3"
  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "govuk/infra-vpc.tfstate"
    region = data.aws_region.current.name
  }
}
