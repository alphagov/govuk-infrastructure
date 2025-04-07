output "cache_endpoints" {
  description = "Name and Endpoint of each Elasticache created"
  value = {
    for name in aws_elasticache_replication_group.cache : name.replication_group_id => name.primary_endpoint_address
  }
}

output "security_group_id" {
  description = "ID of the Security Group created"
  value       = aws_security_group.cache.id
}

output "route53_records" {
  description = "Name and Endpoint Address for each record created"
  value = {
    for name in aws_route53_record.cache : name.name => name.records
  }
}
