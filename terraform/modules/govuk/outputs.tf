output "publisher_security_groups" {
  value       = module.publisher_service.security_groups
  description = "The security groups applied to the Publisher ECS Service."
}

output "frontend_security_groups" {
  value       = module.frontend_service.security_groups
  description = "The security groups applied to the Frontend ECS Service."
}

output "signon_security_groups" {
  value       = module.signon_service.security_groups
  description = "The security groups applied to the Signon ECS Service."
}

output "content_store_security_groups" {
  value       = module.content_store_service.security_groups
  description = "The security groups applied to the Content Store ECS Service."
}

output "draft_content_store_security_groups" {
  value       = module.draft_content_store_service.security_groups
  description = "The security groups applied to the Draft Content Store ECS Service."
}
