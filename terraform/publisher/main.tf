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

data "aws_iam_role" "task_role" {
  name = "fargate_task_role"
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = "govuk"
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("../task-definitions/publisher.json")
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = data.aws_iam_role.task_execution_role.arn
  task_role_arn            = data.aws_iam_role.task_role.arn

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"

    properties = {
      AppPorts         = "3000"
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
      IgnoredUID       = "1337"
      ProxyEgressPort  = 15001
      ProxyIngressPort = 15000
    }
  }
}

resource "aws_ecs_service" "service" {
  name                              = var.service_name
  cluster                           = data.aws_ecs_cluster.cluster.id
  task_definition                   = aws_ecs_task_definition.service.arn
  desired_count                     = var.desired_count
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 60

  network_configuration {
    security_groups = [
      aws_security_group.service.id,
      aws_security_group.public_service.id,
      var.govuk_management_access_security_group,
      aws_security_group.publisher_dependencies.id, # Allows Publisher to talk to Dependencies
    ]
    subnets = var.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.public_lb_tg.arn
    container_name   = var.service_name
    container_port   = var.container_ingress_port
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.publisher.arn
    container_name = "publisher"
  }

  depends_on = [
    aws_lb_listener.public_listener,
    aws_service_discovery_service.publisher
  ]
}

#
# ECS Service Security groups
#

resource "aws_security_group" "service" {
  name        = "fargate_${var.service_name}_alb_access"
  vpc_id      = data.aws_vpc.vpc.id
  description = "Allow the public and internal ALBs for the fargate ${var.service_name} service to access the service"
}

resource "aws_security_group_rule" "service_ingress" {
  description = "Allow publisher ingress to publishing-api"
  type        = "ingress"
  from_port   = "80"
  to_port     = "80"
  protocol    = "tcp"

  security_group_id        = var.publishing_api_ingress_security_group
  source_security_group_id = aws_security_group.publisher_dependencies.id
}

#
# Public Load balancer
#

# Certificates needed for the public load balancer
data "aws_acm_certificate" "default_public_elb_cert" {
  domain   = "*.test.govuk.digital"
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "public_elb_cert" {
  domain   = "*.test.publishing.service.gov.uk"
  statuses = ["ISSUED"]
}

# The public Application Load Balancer (ALB)
resource "aws_lb" "public" {
  name               = "fargate-public-${var.service_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb.id]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "public_lb_tg" {
  name        = "${var.service_name}-public"
  port        = var.container_ingress_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    path = "/healthcheck"
  }

  depends_on = [aws_lb.public]
}

resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = aws_lb.public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.default_public_elb_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_lb_tg.arn
  }
}

# Adds .publishing.service.gov.uk cert to ALB listener
resource "aws_lb_listener_certificate" "publishing_service_listener_cert" {
  listener_arn    = aws_lb_listener.public_listener.arn
  certificate_arn = data.aws_acm_certificate.public_elb_cert.arn
}

resource "aws_security_group_rule" "public_alb_ingress" {
  type      = "ingress"
  from_port = var.container_ingress_port
  to_port   = var.container_ingress_port
  protocol  = "tcp"

  # Which security group is the rule assigned to
  security_group_id = aws_security_group.public_service.id

  # Which security group can use this rule
  source_security_group_id = aws_security_group.public_alb.id
}

resource "aws_security_group" "public_alb" {
  name        = "fargate_${var.service_name}_public_elb"
  vpc_id      = data.aws_vpc.vpc.id
  description = "Public ALB ingress and egress security group for ${var.service_name} ECS service"

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

resource "aws_security_group" "public_service" {
  name        = "fargate_public_${var.service_name}_elb_access"
  vpc_id      = data.aws_vpc.vpc.id
  description = "Access to the fargate ${var.service_name} service from its public ELB"
}

#
# Redis
#

resource "aws_security_group" "publisher_dependencies" {
  name        = "fargate_${var.service_name}_app"
  vpc_id      = data.aws_vpc.vpc.id
  description = "${var.service_name} service dependencies"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ingress_redis" {
  type      = "ingress"
  from_port = 6379
  to_port   = 6379
  protocol  = "tcp"

  # Which security group is the rule assigned to
  security_group_id = var.redis_security_group_id

  # Which security group can use this rule
  source_security_group_id = aws_security_group.publisher_dependencies.id
}

#
# DocumentDB
#
resource "aws_security_group_rule" "ingress_documentdb" {
  type      = "ingress"
  from_port = 27017
  to_port   = 27017
  protocol  = "tcp"

  # Which security group is the rule assigned to
  security_group_id = var.documentdb_security_group_id

  # Which security group can use this rule
  source_security_group_id = aws_security_group.publisher_dependencies.id
}

#
# DNS
#

data "aws_route53_zone" "public" {
  name         = var.public_domain_name
  private_zone = false
}

resource "aws_route53_record" "public_service_record" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${var.service_name}.${var.public_domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = false
  }
}
