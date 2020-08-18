data "aws_vpc" "vpc" {
  id = "vpc-9e62bcf8"
}

data "aws_acm_certificate" "elb_cert" {
  domain   = "*.test.govuk-internal.digital"
  statuses = ["ISSUED"]
}

data "aws_iam_role" "task_execution_role" {
  name = "fargate_task_execution_role"
}

#
# Load balancer
#

resource "aws_lb" "alb" {
  name               = "fargate-${var.service_name}-alb"
  internal           = "true"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.private_subnets
}

resource "aws_lb_target_group" "lb_tg" {
  name        = "${var.service_name}-lb-tg"
  port        = var.container_ingress_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    path      = "/healthcheck"
    timeout   = 30
    interval  = 60
  }
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

resource "aws_security_group" "service_sg" {
  name        = "fargate_${var.service_name}_elb_access"
  vpc_id      = data.aws_vpc.vpc.id
  description = "Access to the fargate ${var.service_name} service from its ELB"
}

resource "aws_security_group_rule" "ingress_alb_http" {
  type      = "ingress"
  from_port = var.container_ingress_port
  to_port   = var.container_ingress_port
  protocol  = "tcp"

  # Which security group is the rule assigned to
  security_group_id = aws_security_group.service_sg.id

  # Which security group can use this rule
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group" "alb_sg" {
  name        = "fargate_${var.service_name}_elb"
  vpc_id      = data.aws_vpc.vpc.id
  description = "ALB ingress and egress security group for ${var.service_name} ECS service"

  ingress {
    description = "${var.service_name} can be spoken to by the Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
    security_groups = [aws_security_group.service_sg.id, var.govuk_management_access_security_group]
    subnets         = var.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = var.service_name
    container_port   = var.container_ingress_port
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  container_definitions    = var.container_definitions
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  execution_role_arn       = data.aws_iam_role.task_execution_role.arn
}
