output "app_security_group_id" {
  value       = module.app.security_group_id
  description = "ID of the security group for Static app instances."
}

output "alb_security_group_id" {
  value       = aws_security_group.public_alb.id
  description = "ID of the security group for the Static app's Internet-facing load balancer."
}

output "security_groups" {
  value       = module.app.security_groups
  description = "The security groups applied to the ECS Service."
}
