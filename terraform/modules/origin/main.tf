locals {
  mode = var.live ? "www" : "draft"
}


# TODO: use a single, ACM-managed cert with both domains on. There is already
# such a cert in integration/staging/prod (but it needs defining in Terraform).
data "aws_acm_certificate" "public_lb_default" {
  domain   = "*.${var.publishing_service_domain}"
  statuses = ["ISSUED"]
}

resource "aws_lb_listener_certificate" "service" {
  listener_arn    = aws_lb_listener.origin.arn
  certificate_arn = var.certificate
}

resource "aws_lb" "origin" {
  name               = "${local.mode}-origin-ecs-${var.workspace_suffix}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.origin_alb.id]
  subnets            = var.public_subnets
}


resource "aws_lb_target_group" "origin-frontend" {
  name        = "${local.mode}-origin-frontend-${var.workspace_suffix}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "origin-frontend" {
  listener_arn = aws_lb_listener.origin.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.origin-frontend.arn
  }

  condition {
    path_pattern {
      values = ["/assets/frontend/*"]
    }
  }
}

resource "aws_lb_target_group" "origin-static" {
  name        = "${local.mode}-origin-static-${var.workspace_suffix}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/templates/core_layout.html.erb"
  }
}

resource "aws_lb_listener_rule" "origin-static" {
  listener_arn = aws_lb_listener.origin.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.origin-static.arn
  }

  condition {
    path_pattern {
      values = ["/assets/static/*"]
    }
  }
}

resource "aws_lb_listener" "origin" {
  load_balancer_arn = aws_lb.origin.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.public_lb_default.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.origin-frontend.arn
  }
}

data "aws_route53_zone" "public" {
  name = var.external_app_domain
}

resource "aws_route53_record" "origin_alb" {
  zone_id = var.public_zone_id
  name    = "${local.mode}-origin-ecs" # TODO: Change to www-origin
  type    = "A"

  alias {
    name                   = aws_lb.origin.dns_name
    zone_id                = aws_lb.origin.zone_id
    evaluate_target_health = true
  }
}
