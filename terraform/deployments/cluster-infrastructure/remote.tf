data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "infra_networking" {
  backend = "s3"
  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "govuk/infra-networking.tfstate"
    region = data.aws_region.current.name
  }
}
