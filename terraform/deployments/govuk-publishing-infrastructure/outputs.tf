output "shared_redis_cluster_host" {
  value = aws_route53_record.shared_redis_cluster.fqdn
}
