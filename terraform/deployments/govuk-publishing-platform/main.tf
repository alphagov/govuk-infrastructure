terraform {
  backend "s3" {
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.33"
    }

    fastly = {
      source  = "fastly/fastly"
      version = "0.24.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = var.assume_role_arn
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"

  assume_role {
    role_arn = var.assume_role_arn
  }
}

provider "fastly" {
  # We only want to use fastly's data API
  api_key = "test"
}

provider "random" {}

locals {
  vpc_id                       = data.terraform_remote_state.infra_networking.outputs.vpc_id
  private_subnets              = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
  public_subnets               = data.terraform_remote_state.infra_networking.outputs.public_subnet_ids
  redis_subnets                = data.terraform_remote_state.infra_networking.outputs.private_subnet_elasticache_ids
  documentdb_security_group_id = data.terraform_remote_state.infra_security_groups.outputs.sg_shared_documentdb_id
  postgresql_security_group_id = data.terraform_remote_state.infra_security_groups.outputs.sg_postgresql-primary_id
  mongodb_security_group_id    = data.terraform_remote_state.infra_security_groups.outputs.sg_mongo_id
  mysql_security_group_id      = data.terraform_remote_state.infra_security_groups.outputs.sg_mysql-primary_id
  routerdb_security_group_id   = data.terraform_remote_state.infra_security_groups.outputs.sg_router-backend_id
  log_group                    = terraform.workspace == "default" ? "govuk" : "govuk-${terraform.workspace}"
}

locals {
  additional_tags = {
    chargeable_entity    = "govuk-publishing-platform-${terraform.workspace}"
    environment          = var.govuk_environment
    project              = "replatforming"
    repository           = "govuk-infrastructure"
    terraform_deployment = "govuk-publishing-platform"
    terraform_workspace  = terraform.workspace
  }
}
