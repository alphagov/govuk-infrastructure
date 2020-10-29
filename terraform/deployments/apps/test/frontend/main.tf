terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/frontend.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.69"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "task_definition" {
  source = "../../../../modules/task-definitions/frontend"

  asset_host                       = local.asset_host
  execution_role_arn               = data.aws_iam_role.execution.arn
  govuk_website_root               = local.govuk_website_root
  image_tag                        = var.image_tag
  mesh_name                        = local.mesh_name
  sentry_environment               = local.sentry_environment
  service_discovery_namespace_name = local.service_discovery_namespace_name
  statsd_host                      = local.statsd_host
  task_role_arn                    = data.aws_iam_role.task.arn
}
