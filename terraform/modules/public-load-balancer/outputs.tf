output "target_group_arn" {
  value = aws_lb_target_group.public.arn
}

output "fqdn" {
  value = "${aws_route53_record.public_alb.name}.${var.public_lb_domain_name}"
}
