terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/draft-content-store.tfstate"
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
  source                           = "../../../modules/task-definitions/content-store"
  service_name                     = "draft-content-store"
  govuk_app_domain_external        = var.app_domain
  govuk_website_root               = local.website_root
  image_tag                        = "bill-content-schemas" # TODO: Change back once content schemas are available
  mesh_name                        = var.mesh_name
  mongodb_url                      = "mongodb://${var.mongodb_host}/draft_content_store_production"
  router_api_hostname_prefix       = "draft-"
  service_discovery_namespace_name = local.service_discovery_namespace_name
  statsd_host                      = local.statsd_host
  execution_role_arn               = data.aws_iam_role.execution.arn
  task_role_arn                    = data.aws_iam_role.task.arn
  sentry_environment               = var.sentry_environment
  assume_role_arn                  = var.assume_role_arn
}
