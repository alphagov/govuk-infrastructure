data "aws_vpc" "govuk-test" {
  id = "vpc-9e62bcf8"
}

resource "aws_ecs_cluster" "cluster" {
  name               = var.service_name
  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets = ["subnet-ba30f6f2"]
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  container_definitions    = var.container_definitions
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
}
