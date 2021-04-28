resource "aws_lb" "origin" {
  name               = "${var.name}-origin-${var.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.origin_alb.id]
  subnets            = var.public_subnets
  
  tags = merge(
    var.additional_tags,
    {
      name           = "${var.name}-lb"
    },
  )
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

resource "aws_route53_record" "origin_alb" {
  zone_id = var.public_zone_id
  name    = "${var.subdomain}-alb"
  type    = "A"

  alias {
    name                   = aws_lb.origin.dns_name
    zone_id                = aws_lb.origin.zone_id
    evaluate_target_health = true
  }
}
