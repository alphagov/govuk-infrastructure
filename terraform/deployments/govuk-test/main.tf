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

module "govuk" {
  source                = "../../modules/govuk"
  mesh_name             = var.mesh_name
  mesh_domain           = var.mesh_domain
  public_lb_domain_name = var.public_lb_domain_name
  internal_domain_name  = var.internal_domain_name

  ecs_default_capacity_provider = var.ecs_default_capacity_provider

  vpc_id                            = data.terraform_remote_state.infra_networking.outputs.vpc_id
  private_subnets                   = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
  public_subnets                    = data.terraform_remote_state.infra_networking.outputs.public_subnet_ids
  redis_subnets                     = data.terraform_remote_state.infra_networking.outputs.private_subnet_elasticache_ids
  govuk_management_access_sg_id     = data.terraform_remote_state.infra_security_groups.outputs.sg_management_id
  documentdb_security_group_id      = data.terraform_remote_state.infra_security_groups.outputs.sg_shared_documentdb_id
  postgresql_security_group_id      = data.terraform_remote_state.infra_security_groups.outputs.sg_postgresql-primary_id
  mongodb_security_group_id         = data.terraform_remote_state.infra_security_groups.outputs.sg_mongo_id
  mysql_security_group_id           = data.terraform_remote_state.infra_security_groups.outputs.sg_mysql-primary_id
  routerdb_security_group_id        = data.terraform_remote_state.infra_security_groups.outputs.sg_router-backend_id
  office_cidrs_list                 = var.office_cidrs_list
  frontend_desired_count            = var.frontend_desired_count
  draft_frontend_desired_count      = var.draft_frontend_desired_count
  publisher_desired_count           = var.publisher_desired_count
  publishing_api_desired_count      = var.publishing_api_desired_count
  router_desired_count              = var.router_desired_count
  draft_router_desired_count        = var.draft_router_desired_count
  router_api_desired_count          = var.router_api_desired_count
  draft_router_api_desired_count    = var.draft_router_api_desired_count
  content_store_desired_count       = var.content_store_desired_count
  draft_content_store_desired_count = var.draft_content_store_desired_count
  signon_desired_count              = var.signon_desired_count
  static_desired_count              = var.static_desired_count
  draft_static_desired_count        = var.draft_static_desired_count
}
