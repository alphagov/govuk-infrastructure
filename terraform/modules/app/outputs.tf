output "required_secrets" {
  value       = values(var.secrets_from_arns)
  description = "ARNs of SecretsManager secrets required by this app."
}

output "security_group_id" {
  value       = aws_security_group.service.id
  description = "ID of the security group created by the module, containing the app."
}

# TODO: Remove this once all uses of ECS RunTask use network_config instead
output "security_groups" {
  value       = local.service_security_groups
  description = "The security groups applied to the ECS Service."
}

output "virtual_service_name" {
  value       = module.service_mesh_node.virtual_service_name
  description = "App Mesh virtual service for this app"
}
