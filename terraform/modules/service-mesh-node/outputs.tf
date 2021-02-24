output "discovery_service_arn" {
  value = aws_service_discovery_service.service.arn
}

output "virtual_service_name" {
  value = aws_appmesh_virtual_service.service.name
}
