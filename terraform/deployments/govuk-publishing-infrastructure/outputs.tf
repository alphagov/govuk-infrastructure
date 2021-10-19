output "shared_redis_cluster_host" {
  value = aws_route53_record.shared_redis_cluster_internal_service_record.fqdn
}

output "shared_redis_cluster_port" {
  value = var.shared_redis_cluster_port
}
