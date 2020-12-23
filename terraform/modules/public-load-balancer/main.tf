# TODO: use a single, ACM-managed cert with both domains on. There is already
# such a cert in integration/staging/prod (but it needs defining in Terraform).
data "aws_acm_certificate" "public_lb_default" {
  domain   = "*.${var.public_lb_domain_name}"
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "public_lb_alternate" {
  domain   = "*.${var.app_domain}"
  statuses = ["ISSUED"]
}

resource "aws_lb_listener_certificate" "service" {
  listener_arn    = aws_lb_listener.public.arn
  certificate_arn = data.aws_acm_certificate.public_lb_alternate.arn
}

resource "aws_lb" "public" {
  name               = "public-${var.app_name}-${var.workspace_suffix}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb.id]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "public" {
  name        = "${var.app_name}-${var.workspace_suffix}-public"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = var.health_check_path
  }
}

resource "aws_lb_listener" "public" {
  load_balancer_arn = aws_lb.public.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.public_lb_default.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public.arn
  }
}

data "aws_route53_zone" "public" {
  name = var.public_lb_domain_name
}

resource "aws_route53_record" "public_alb" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = var.dns_a_record_name
  type    = "A"

  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }
}
