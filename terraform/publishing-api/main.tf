terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/app-publishing-api.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  version = "~> 2.69"
  region  = "eu-west-1"
}

#
# Data
#

data "aws_vpc" "vpc" {
  id = "vpc-9e62bcf8"
}

#
# ECS Cluster, Service, Task
#

data "aws_iam_role" "task_execution_role" {
  name = "fargate_task_execution_role"
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = "govuk"
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("../task-definitions/publishing-api.json")
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = data.aws_iam_role.task_execution_role.arn
}

resource "aws_ecs_service" "service" {
  name                              = var.service_name
  cluster                           = data.aws_ecs_cluster.cluster.id
  task_definition                   = aws_ecs_task_definition.service.arn
  desired_count                     = var.desired_count
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 300

  network_configuration {
    security_groups = [aws_security_group.service.id, var.govuk_management_access_security_group, data.aws_security_group.service_dependencies.id]
    subnets         = var.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.internal_lb_tg.arn
    container_name   = var.service_name
    container_port   = var.container_ingress_port
  }
}

#
# ECS Service Security groups
#

resource "aws_security_group" "service" {
  name        = "fargate_${var.service_name}_alb_access"
  vpc_id      = data.aws_vpc.vpc.id
  description = "Allow the internal ALB for the fargate ${var.service_name} service to access the service"
}

#
# Internal Load balancer
#

data "aws_acm_certificate" "internal_elb_cert" {
  domain   = "*.test.govuk-internal.digital"
  statuses = ["ISSUED"]
}

resource "aws_lb" "internal_alb" {
  name               = "fargate-${var.service_name}"
  internal           = "true"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb_sg.id]
  subnets            = var.private_subnets
}

resource "aws_lb_target_group" "internal_lb_tg" {
  name        = "${var.service_name}-internal"
  port        = var.container_ingress_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"

  deregistration_delay = 10

  health_check {
    path = "/healthcheck"
  }
}

resource "aws_lb_listener" "internal_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.internal_elb_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_lb_tg.arn
  }
}

resource "aws_security_group_rule" "internal_alb_ingress" {
  type      = "ingress"
  from_port = var.container_ingress_port
  to_port   = var.container_ingress_port
  protocol  = "tcp"

  security_group_id        = aws_security_group.service.id
  source_security_group_id = aws_security_group.internal_alb_sg.id
}

resource "aws_security_group" "internal_alb_sg" {
  name        = "fargate_${var.service_name}_elb"
  vpc_id      = data.aws_vpc.vpc.id
  description = "ALB ingress and egress security group for ${var.service_name} ECS service"

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.govuk_management_access_security_group] # TODO create a security group for talking to publishing-api ALB.
  }

  egress {
    from_port       = var.container_ingress_port
    to_port         = var.container_ingress_port
    protocol        = "tcp"
    security_groups = [aws_security_group.service.id]
  }
}

#
# Dependencies
#

data "aws_security_group" "service_dependencies" {
  id = "sg-05ad7398fc0d7c5b4" # govuk_publishing-api_access
}

#
# DNS
#

data "aws_route53_zone" "internal" {
  name         = var.internal_domain_name
  private_zone = true
}

resource "aws_route53_record" "internal_service_record" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "${var.service_name}.${var.internal_domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.internal_alb.dns_name
    zone_id                = aws_lb.internal_alb.zone_id
    evaluate_target_health = false
  }
}
