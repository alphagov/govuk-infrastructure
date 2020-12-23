terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/monitoring.tfstate"
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

data "terraform_remote_state" "govuk" {
  backend = "s3"
  config = {
    bucket   = "govuk-terraform-test"
    key      = "projects/govuk.tfstate"
    region   = "eu-west-1"
    role_arn = var.assume_role_arn
  }
}

module "monitoring" {
  source                = "../../../modules/monitoring"
  public_lb_domain_name = var.public_lb_domain_name

  vpc_id                        = data.terraform_remote_state.infra_networking.outputs.vpc_id
  private_subnets               = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
  public_subnets                = data.terraform_remote_state.infra_networking.outputs.public_subnet_ids
  govuk_management_access_sg_id = data.terraform_remote_state.infra_security_groups.outputs.sg_management_id
  office_cidrs_list             = var.office_cidrs_list
}
