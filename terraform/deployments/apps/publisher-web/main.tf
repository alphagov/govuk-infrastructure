terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/publisher-web.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.13"
    }
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = var.assume_role_arn
  }
}

data "aws_region" "current" {}

data "terraform_remote_state" "govuk" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket   = "govuk-terraform-${var.govuk_environment}"
    key      = "projects/govuk.tfstate"
    region   = data.aws_region.current.name
    role_arn = var.assume_role_arn
  }
}

module "network_config" {
  source          = "../../../modules/task-network-config"
  subnets         = data.terraform_remote_state.govuk.outputs.private_subnets
  security_groups = data.terraform_remote_state.govuk.outputs.publisher-web_security_groups
}

module "task_definition" {
  source                           = "../../../modules/task-definitions/publisher"
  govuk_app_domain_external        = var.app_domain
  govuk_website_root               = local.website_root
  image_tag                        = var.image_tag
  mesh_name                        = var.mesh_name
  service_discovery_namespace_name = local.service_discovery_namespace_name
  statsd_host                      = local.statsd_host
  execution_role_arn               = data.aws_iam_role.execution.arn
  task_role_arn                    = data.aws_iam_role.task.arn
  redis_host                       = var.redis_host
  redis_port                       = local.redis_port
  service_name                     = "publisher-web"
  asset_host                       = local.asset_host
  sentry_environment               = var.sentry_environment
  assume_role_arn                  = var.assume_role_arn
}
