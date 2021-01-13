terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/static.tfstate"
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

module "task_definition" {
  source                           = "../../../modules/task-definitions/static"
  service_name                     = "static"
  image_tag                        = var.image_tag
  mesh_name                        = var.mesh_name
  execution_role_arn               = data.aws_iam_role.execution.arn
  assets_url                       = local.assets_url
  redis_host                       = var.redis_host
  redis_port                       = local.redis_port
  task_role_arn                    = data.aws_iam_role.task.arn
  sentry_environment               = var.sentry_environment
  assume_role_arn                  = var.assume_role_arn
  service_discovery_namespace_name = local.service_discovery_namespace_name
  statsd_host                      = local.statsd_host
  govuk_app_domain_external        = var.app_domain
  govuk_website_root               = local.website_root
}
