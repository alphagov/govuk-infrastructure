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
  source                           = "../../../modules/task-definitions/frontend"
  service_name                     = "frontend"
  assets_url                       = local.assets_url
  content_store_url                = local.content_store_url
  static_url                       = local.static_url
  execution_role_arn               = data.aws_iam_role.execution.arn
  govuk_website_root               = local.website_root
  image_tag                        = var.image_tag
  mesh_name                        = var.mesh_name
  sentry_environment               = var.sentry_environment
  service_discovery_namespace_name = local.service_discovery_namespace_name
  statsd_host                      = local.statsd_host
  task_role_arn                    = data.aws_iam_role.task.arn
  assume_role_arn                  = var.assume_role_arn
}
