output "publisher_security_groups" {
  value       = module.publisher_service.security_groups
  description = "The security groups applied to the Publisher ECS Service."
}
