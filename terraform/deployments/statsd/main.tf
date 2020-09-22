terraform {
  backend "s3" {
    bucket  = "govuk-terraform-test"
    key     = "projects/statsd.tfstate"
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

data "aws_acm_certificate" "elb_cert" {
  domain   = "*.test.govuk-internal.digital"
  statuses = ["ISSUED"]
}

data "aws_iam_role" "task_execution_role" {
  name = "fargate_task_execution_role"
}

data "aws_route53_zone" "internal" {
  name         = var.internal_domain_name
  private_zone = true
}

#
# DNS
#

resource "aws_route53_record" "internal_service_names" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "${var.service_name}.${var.internal_domain_name}"
  type    = "CNAME"
  records = ["${var.service_name}.pink.${var.internal_domain_name}"]
  ttl     = "300"
}

resource "aws_route53_record" "internal_service_record" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "${var.service_name}.pink.${var.internal_domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

#
# Network load balancer
#

resource "aws_lb" "alb" {
  name               = "fargate-${var.service_name}-alb"
  internal           = "true"
  load_balancer_type = "network"
  subnets            = var.private_subnets
}

resource "aws_lb_target_group" "lb_tg" {
  name        = "${var.service_name}-lb-tg"
  port        = 8125
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"
}

# Forwards LB requests to the Fargate targets
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 8125
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "fargate_${var.service_name}_elb_access"
  vpc_id      = data.aws_vpc.vpc.id
  description = "Access to the fargate ${var.service_name} service from its ELB"
}

resource "aws_security_group_rule" "ingress_alb_tcp" {
  type      = "ingress"
  from_port = 8125
  to_port   = 8125
  protocol  = "tcp"

  security_group_id = aws_security_group.alb_sg.id

  cidr_blocks = [data.aws_vpc.vpc.cidr_block]
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
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.alb_sg.id, var.govuk_management_access_security_group]
    subnets         = var.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = var.service_name
    container_port   = 8125
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("statsd.json")
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  execution_role_arn       = data.aws_iam_role.task_execution_role.arn
}
