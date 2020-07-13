data "aws_vpc" "vpc" {
  id = "vpc-9e62bcf8"
}

data "aws_acm_certificate" "elb_cert" {
  domain   = "*.test.govuk-internal.digital"
  statuses = ["ISSUED"]
}

#
# Load balancer
#

resource "aws_lb" "alb" {
  name            = "fargate-${var.service_name}-alb"
  internal        = "true"
  load_balancer_type = "application"
  security_groups = ["sg-0e63eaee8bd5f4315"] # frontend elb security group
  subnets         = ["subnet-6dc4370b", "subnet-463bfd0e", "subnet-bfecd0e4"] # govuk_private_abc
}

resource "aws_lb_target_group" "lb_tg" {
  name     = "${var.service_name}-lb-tg"
  port     = 3005
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc.id
  target_type = "ip"
}

# Forwards LB requests to the Fargate targets
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # TODO: Don't know if correct
  certificate_arn   = data.aws_acm_certificate.elb_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

resource "aws_security_group" "frontend" {
  name        = "fargate_frontend_access"
  vpc_id      = data.aws_vpc.vpc.id
  description = "Access to the fargate frontend host from its ELB"
}

resource "aws_security_group_rule" "frontend_ingress_frontend-elb_http" {
  type      = "ingress"
  from_port = 3005
  to_port   = 3005
  protocol  = "tcp"

  # Which security group is the rule assigned to
  security_group_id = aws_security_group.frontend.id

  # Which security group can use this rule
  source_security_group_id = "sg-0e63eaee8bd5f4315"
}

#
# IAM role for Fargate tasks
#

resource "aws_iam_role" "task_execution_role" {
  name = "fargate_task_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "create_log_group_policy" {
  name        = "create_log_group_policy"
  path        = "/createLogsGroupPolicy/"
  description = "Create Logs group"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "logs:CreateLogGroup",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Allow tasks to create log groups
resource "aws_iam_role_policy_attachment" "log_group_attachment_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.create_log_group_policy.arn
}

# Attach managed AmazonECSTaskExecutionRolePolicy policy to task execution role
resource "aws_iam_role_policy_attachment" "task_exec_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#
# ECS Cluster, Service, Task
#

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
    security_groups = [aws_security_group.frontend.id, "sg-0b873470482f6232d"]
    subnets = ["subnet-6dc4370b", "subnet-463bfd0e", "subnet-bfecd0e4"] # govuk_private_abc
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = var.service_name
    container_port   = 3005
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  container_definitions    = var.container_definitions
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  execution_role_arn       = aws_iam_role.task_execution_role.arn
}
