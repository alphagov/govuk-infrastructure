output "security_group_id" {
  value       = aws_security_group.service.id
  description = "ID of the security group for Statsd ECS Service."
}

output "virtual_service_name" {
  value       = module.service_mesh_node.virtual_service_name
  description = "Statsd App Mesh Virtual Service"
}
