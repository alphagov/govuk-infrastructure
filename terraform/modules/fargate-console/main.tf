data "aws_vpc" "vpc" {
  id = "vpc-9e62bcf8"
}

data "aws_iam_role" "task_execution_role" {
  name = "fargate_task_execution_role"
}

#
# ECS Task Definition
#

resource "aws_ecs_task_definition" "console_definition" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  container_definitions    = var.container_definitions
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = data.aws_iam_role.task_execution_role.arn
}
