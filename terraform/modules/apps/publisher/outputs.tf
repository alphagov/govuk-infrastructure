output "app_security_group_id" {
  value       = module.app.security_group_id
  description = "ID of the security group for Publisher app instances."
}

output "alb_security_group_id" {
  value       = module.public_alb.security_group_id
  description = "ID of the security group for the Publisher app's Internet-facing load balancer."
}

output "security_groups" {
  value       = module.app.security_groups
  description = "The security groups applied to the ECS Service."
}
