output "app_security_group_id" {
  value       = module.app.security_group_id
  description = "ID of the security group for Content Store (or draft) instances."
}

output "security_groups" {
  value       = module.app.security_groups
  description = "The security groups applied to the ECS Service."
}
