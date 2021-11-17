resource "aws_elasticache_subnet_group" "shared_redis_cluster_subnet_group" {
  name       = var.shared_redis_cluster_name
  subnet_ids = local.redis_subnets
}

resource "aws_security_group" "shared_redis_cluster" {
  name        = var.shared_redis_cluster_name
  vpc_id      = local.vpc_id
  description = "Access to the ${var.shared_redis_cluster_name} Redis cluster"

  tags = merge(
    local.default_tags,
    {
      Name = "${var.shared_redis_cluster_name}"
    },
  )

}

resource "aws_elasticache_replication_group" "shared_redis_cluster" {
  apply_immediately             = var.govuk_environment != "production" ? true : false
  replication_group_id          = var.shared_redis_cluster_name
  replication_group_description = "${var.shared_redis_cluster_name} Redis cluster with Redis master and replica"
  node_type                     = var.shared_redis_cluster_node_type
  port                          = var.shared_redis_cluster_port
  number_cache_clusters         = 2
  parameter_group_name          = "default.redis6.x"
  automatic_failover_enabled    = true
  engine_version                = "6.x"
  subnet_group_name             = aws_elasticache_subnet_group.shared_redis_cluster_subnet_group.name
  security_group_ids            = [aws_security_group.shared_redis_cluster.id]

  tags = merge(
    local.default_tags,
    {
      Name = "${var.shared_redis_cluster_name}"
    },
  )

}

resource "aws_route53_record" "shared_redis_cluster_internal_service_record" {
  zone_id = local.internal_dns_zone_id
  # TODO: consider removing EKS suffix once the old EC2 environments are gone.
  name    = "${var.shared_redis_cluster_name}.eks"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_replication_group.shared_redis_cluster.primary_endpoint_address]
}
