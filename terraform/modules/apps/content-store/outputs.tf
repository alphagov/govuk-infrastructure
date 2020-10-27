output "app_security_group_id" {
  value       = module.app.security_group_id
  description = "ID of the security group for Content Store (or draft) instances."
}

output "image_tag" {
  value       = var.image_tag
  description = "The last provided image tag"
}
