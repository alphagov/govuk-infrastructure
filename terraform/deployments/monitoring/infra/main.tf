terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/monitoring.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.33"
    }
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = var.assume_role_arn
  }
}

data "terraform_remote_state" "infra_networking" {
  backend = "s3"
  config = {
    bucket   = var.govuk_aws_state_bucket
    key      = "govuk/infra-networking.tfstate"
    region   = "eu-west-1"
    role_arn = var.assume_role_arn
  }
}

data "terraform_remote_state" "infra_security_groups" {
  backend = "s3"
  config = {
    bucket   = var.govuk_aws_state_bucket
    key      = "govuk/infra-security-groups.tfstate"
    region   = "eu-west-1"
    role_arn = var.assume_role_arn
  }
}

data "terraform_remote_state" "govuk" {
  backend = "s3"
  config = {
    bucket   = "govuk-terraform-test"
    key      = "projects/govuk.tfstate"
    region   = "eu-west-1"
    role_arn = var.assume_role_arn
  }
}

data "aws_secretsmanager_secret" "splunk_url" {
  name = "SPLUNK_HEC_URL"
}

data "aws_secretsmanager_secret" "splunk_token" {
  name = "SPLUNK_TOKEN"
}

locals {
  workspace = terraform.workspace == "default" ? "ecs" : terraform.workspace #default terraform workspace mapped to ecs
  additional_tags = {
    chargeable_entity    = "monitoring"
    environment          = var.govuk_environment
    project              = "replatforming"
    repository           = "govuk-infrastructure"
    terraform_deployment = "monitoring"
    terraform_workspace  = local.workspace
  }
}

module "monitoring" {
  source                    = "../../../modules/monitoring"
  external_app_domain       = var.external_app_domain
  publishing_service_domain = var.publishing_service_domain

  splunk_url_secret_arn   = data.aws_secretsmanager_secret.splunk_url.arn
  splunk_token_secret_arn = data.aws_secretsmanager_secret.splunk_token.arn
  splunk_sourcetype       = "log"
  splunk_index            = "govuk_replatforming"

  vpc_id                        = data.terraform_remote_state.infra_networking.outputs.vpc_id
  private_subnets               = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
  public_subnets                = data.terraform_remote_state.infra_networking.outputs.public_subnet_ids
  govuk_management_access_sg_id = data.terraform_remote_state.infra_security_groups.outputs.sg_management_id
  grafana_cidrs_allow_list      = concat(var.office_cidrs_list, var.concourse_cidrs_list)
  govuk_environment             = var.govuk_environment
  workspace                     = local.workspace
  additional_tags               = local.additional_tags
  capacity_provider             = var.ecs_default_capacity_provider
}
