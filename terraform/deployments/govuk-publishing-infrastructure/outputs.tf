output "shared_redis_cluster_host" {
  value = aws_route53_record.shared_redis_cluster.fqdn
}

output "eks_ingress_www_origin_security_group_name" {
  value = aws_security_group.eks_ingress_www_origin.name
}
