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

module "govuk" {
  source                        = "../../modules/govuk"
  vpc_id                        = var.vpc_id
  mesh_name                     = var.mesh_name
  mesh_domain                   = var.mesh_domain
  private_subnets               = var.private_subnets
  public_subnets                = var.public_subnets
  public_lb_domain_name         = var.public_lb_domain_name
  govuk_management_access_sg_id = data.aws_security_group.govuk_management_access.id
  documentdb_security_group_id  = data.aws_security_group.documentdb.id
  redis_security_group_id       = data.aws_security_group.redis.id
}
