data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

data "tfe_outputs" "networking" {
  organization = "govuk"
  workspace    = "networking-concourse"
}

data "terraform_remote_state" "account_wide" {
  backend = "s3"

  config = {
    key    = "terraform/tools/account-wide.tfstate"
    bucket = "govuk-tools-state-files"
    region = "eu-west-1"

    use_lockfile = true
  }
}

# data "aws_route53_zone" "tools_govuk_digital" {
#   id = data.terraform_remote_state.account_wide.tools_govuk_digital_zone_id
# }
