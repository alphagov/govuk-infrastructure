terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/rake-task.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  version = "~> 2.69"
  region  = "eu-west-1"
}

resource "aws_ecs_cluster" "task_runner" {
  name               = "task_runner"
  capacity_providers = ["FARGATE"]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
