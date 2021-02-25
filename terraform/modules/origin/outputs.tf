output "frontend_target_group_arn" {
  value = aws_lb_target_group.origin-frontend.arn
}

output "static_target_group_arn" {
  value = aws_lb_target_group.origin-static.arn
}

output "security_group_id" {
  value = aws_security_group.origin_alb.id
}

output "fqdn" {
  value = "${aws_route53_record.origin_alb.name}.${var.publishing_service_domain}"
}
