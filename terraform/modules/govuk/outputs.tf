output "service_discovery_private_dns_namespace_id" {
  value       = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.id
  description = "ID of the private DNS namespace for service dicovery"
}

output "service_discovery_private_dns_namespace_name" {
  value       = aws_service_discovery_private_dns_namespace.govuk_publishing_platform.name
  description = "Name of the private DNS namespace for service dicovery"
}

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

output "fargate_execution_iam_role_arn" {
  value = aws_iam_role.execution.arn
}

output "fargate_task_iam_role_arn" {
  value = aws_iam_role.task.arn
}

output "redis_host" {
  value = module.shared_redis_cluster.redis_host
}

output "redis_port" {
  value = module.shared_redis_cluster.redis_port
}
