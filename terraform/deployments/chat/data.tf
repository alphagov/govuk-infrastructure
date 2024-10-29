data "aws_caller_identity" "current" {}

data "aws_region" "current" {
  name = var.aws_region
}

data "tfe_outputs" "cluster_infrastructure" {
  organization = "govuk"
  workspace    = "cluster-infrastructure-${var.govuk_environment}"
}

data "tfe_outputs" "vpc" {
  organization = "govuk"
  workspace    = "vpc-${var.govuk_environment}"
}

data "terraform_remote_state" "infra_networking" {
  backend = "s3"
  config = {
    bucket = var.govuk_aws_state_bucket
    key    = "govuk/infra-networking.tfstate"
    region = var.aws_region
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

data "aws_wafv2_rule_group" "x_always_block" {
  name  = "x-always-block_rule_group"
  scope = "REGIONAL"
}

data "aws_wafv2_ip_set" "govuk_requesting_ips" {
  name  = "govuk_requesting_ips"
  scope = "REGIONAL"
}

data "aws_wafv2_ip_set" "high_request_rate" {
  name  = "high_request_rate"
  scope = "REGIONAL"
}

data "aws_secretsmanager_secret_version" "fastly_token" {
  secret_id = "govuk/govuk-chat/fastly-token"
}
