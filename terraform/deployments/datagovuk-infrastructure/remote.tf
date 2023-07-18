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

data "terraform_remote_state" "app_govuk_rds" {
  backend = "s3"

  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "blue/app-govuk-rds.tfstate"
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
