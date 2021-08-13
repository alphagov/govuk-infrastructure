terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.33"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.1.0"

  cluster_name     = "govuk"
  cluster_version  = "1.21"
  subnets          = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
  vpc_id           = data.terraform_remote_state.infra_networking.outputs.vpc_id
  manage_aws_auth  = false
  write_kubeconfig = false

  cluster_log_retention_in_days = var.cluster_log_retention_in_days
  cluster_enabled_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]

  worker_groups = [
    {
      instance_type        = var.workers_instance_type
      asg_desired_capacity = var.workers_size_desired
      asg_max_size         = var.workers_size_max
      asg_min_size         = var.workers_size_min
      root_volume_type     = "gp3"
    }
  ]
}
