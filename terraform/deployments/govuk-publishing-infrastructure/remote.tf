data "aws_region" "current" {}

data "tfe_outputs" "cluster_infrastructure" {
  organization = "govuk"
  workspace    = "cluster-infrastructure-${var.govuk_environment}"
}

data "tfe_outputs" "vpc" {
  organization = "govuk"
  workspace    = "vpc-${var.govuk_environment}"
}

data "terraform_remote_state" "infra_assets" {
  backend = "s3"
  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "govuk/infra-assets.tfstate"
    region = data.aws_region.current.name
  }
}

data "terraform_remote_state" "infra_content_publisher" {
  backend = "s3"
  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "govuk/infra-content-publisher.tfstate"
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

data "terraform_remote_state" "app_govuk_rds" {
  backend = "s3"

  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "blue/app-govuk-rds.tfstate"
    region = data.aws_region.current.name
  }

  # TODO: hack because govuk-aws/app-govuk-rds is not terraformed in `test`.
  # `test` still uses a single postgres instance for many apps.
  defaults = {
    sg_rds = {}
  }
}

data "terraform_remote_state" "app_search" {
  backend = "s3"

  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "blue/app-search.tfstate"
    region = data.aws_region.current.name
  }
}

data "fastly_ip_ranges" "fastly" {}
