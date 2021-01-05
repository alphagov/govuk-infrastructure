output "security_group_id" {
  value       = aws_security_group.service.id
  description = "ID of the security group for Statsd ECS Service."
}
