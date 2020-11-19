output "security_group_id" {
  value       = module.app.security_group_id
  description = "ID of the security group for signon instances."
}
