output "app_security_group_id" {
  value       = module.app.security_group_id
  description = "ID of the security group for Publisher app instances."
}

output "alb_security_group_id" {
  value       = aws_security_group.public_alb.id
  description = "ID of the security group for the Publisher app's Internet-facing load balancer."
}
