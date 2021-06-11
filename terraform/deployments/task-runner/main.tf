terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 3.13"
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
