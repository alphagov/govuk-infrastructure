resource "aws_lb" "origin" {
  name               = "${local.live_or_draft_prefix}-origin-${var.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.origin_alb.id]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "origin" {
  name        = "${local.live_or_draft_prefix}-origin-${var.workspace}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "origin" {
  load_balancer_arn = aws_lb.origin.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.load_balancer_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access denied"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "authentication" {
  listener_arn = aws_lb_listener.origin.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.origin.arn
  }

  condition {
    http_header {
      http_header_name = "X-Cloudfront-Token"
      values           = [random_password.origin_alb_x_custom_header_secret.result]
    }
  }
}

resource "aws_route53_record" "origin_alb" {
  zone_id = var.public_zone_id
  name    = "${local.live_or_draft_prefix}-origin-alb"
  type    = "A"

  alias {
    name                   = aws_lb.origin.dns_name
    zone_id                = aws_lb.origin.zone_id
    evaluate_target_health = true
  }
}
