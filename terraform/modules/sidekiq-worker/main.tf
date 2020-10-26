terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.69"
    }
  }
}

data "aws_iam_role" "task_execution_role" {
  name = "fargate_execution_role"
}

data "aws_vpc" "vpc" {
  id = "vpc-9e62bcf8"
}

resource "aws_ecs_service" "sidekiq" {
  name            = "publisher-sidekiq"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.service_sg.id, var.govuk_management_access_security_group]
    subnets         = var.private_subnets
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  container_definitions    = jsonencode(var.container_definitions)
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  execution_role_arn       = data.aws_iam_role.task_execution_role.arn
}

resource "aws_security_group" "service_sg" {
  name        = "fargate_${var.service_name}_elb_access"
  vpc_id      = data.aws_vpc.vpc.id
  description = "Access to the fargate ${var.service_name} service from its ELB"
}

variable "govuk_management_access_security_group" {
  description = "Group used to allow access by management systems"
  type        = string
  default     = "sg-0b873470482f6232d"
}

variable "service_name" {
  description = "Name to use for the ECS service, task and other resources. Should normally be the name of the app."
  type        = string
}


