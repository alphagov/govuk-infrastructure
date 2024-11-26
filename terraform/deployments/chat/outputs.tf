output "chat_redis_cluster_host" {
  value = aws_route53_record.chat_redis_cluster.fqdn
}
