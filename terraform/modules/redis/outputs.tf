output "security_group_id" {
  value       = aws_security_group.redis.id
  description = "ID of the security group for Redis cluster"
}

output "service_dns_name" {
  value       = "${aws_route53_record.internal_service_record.fqdn}"
  description = "Internal DNS name to access the Redis service"
}
