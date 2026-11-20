data "aws_region" "current" {}

data "aws_caller_identity" "current" {}


data "tfe_outputs" "networking" {
  organization = "govuk"
  workspace    = "networking-concourse"
}

data "terraform_remote_state" "account_wide" {
  backend = "s3"

  config = {
    key    = "network.tfstate"
    bucket = "govuk-tools-state-files"
    region = data.aws_region.current

    use_lockfile = true
  }
}

data "aws_route53_zone" "tools_govuk_digital" {
  id = data.terraform_remote_state.account_wide.outputs.tools_govuk_digital_zone_id

}
