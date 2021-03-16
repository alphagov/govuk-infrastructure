output "security_group_id" {
  value       = aws_security_group.redis.id
  description = "ID of the security group for Redis cluster"
}

output "uri" {
  value = "redis://${aws_route53_record.internal_service_record.fqdn}:${local.redis_port}"
}

output "redis_port" {
  value = local.redis_port
}
