terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/signon.tfstate"
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
  source                           = "../../../modules/task-definitions/signon"
  image_tag                        = var.image_tag
  execution_role_arn               = data.aws_iam_role.execution.arn
  govuk_app_domain_external        = var.app_domain
  govuk_website_root               = local.website_root
  mesh_name                        = var.mesh_name
  redis_host                       = var.redis_host
  redis_port                       = local.redis_port
  service_discovery_namespace_name = local.service_discovery_namespace_name
  task_role_arn                    = data.aws_iam_role.task.arn
  sentry_environment               = var.sentry_environment
  statsd_host                      = local.statsd_host
  assume_role_arn                  = var.assume_role_arn
}
