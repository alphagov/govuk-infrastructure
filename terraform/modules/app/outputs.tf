output "security_group_id" {
  value       = aws_security_group.service.id
  description = "ID of the security group created by the module, containing the app."
}

output "security_groups" {
  value       = local.service_security_groups
  description = "The security groups applied to the ECS Service."
}
