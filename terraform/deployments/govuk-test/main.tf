terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/govuk.tfstate"
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
}

data "aws_security_group" "documentdb" {
  name = "govuk_shared_documentdb_access"
}

data "aws_security_group" "govuk_management_access" {
  name = "govuk_management_access"
}

data "aws_security_group" "redis" {
  name = "govuk_backend-redis_access"
}

data "terraform_remote_state" "infra_networking" {
  backend = "s3"
  config = {
    bucket = var.infra_networking_state_bucket
    key    = "govuk/infra-networking.tfstate"
    region = "eu-west-1"
  }
}

module "govuk" {
  source                = "../../modules/govuk"
  mesh_name             = var.mesh_name
  mesh_domain           = var.mesh_domain
  public_lb_domain_name = var.public_lb_domain_name

  vpc_id                        = data.terraform_remote_state.infra_networking.outputs.vpc_id
  private_subnets               = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
  public_subnets                = data.terraform_remote_state.infra_networking.outputs.public_subnet_ids
  govuk_management_access_sg_id = data.aws_security_group.govuk_management_access.id
  documentdb_security_group_id  = data.aws_security_group.documentdb.id
  redis_security_group_id       = data.aws_security_group.redis.id
  frontend_desired_count        = var.frontend_desired_count
  content_store_desired_count   = var.content_store_desired_count
}
