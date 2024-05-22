locals {
  chat_redis_name     = "chat-redis"
  elasticache_subnets = data.terraform_remote_state.infra_networking.outputs.private_subnet_elasticache_ids
}

resource "aws_elasticache_subnet_group" "chat_redis_cluster" {
  name       = local.chat_redis_name
  subnet_ids = local.elasticache_subnets
}

resource "aws_security_group" "chat_redis_cluster" {
  name        = local.chat_redis_name
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "GOV.UK Chat Redis cluster"
  tags = {
    Name = local.chat_redis_name
  }
}

resource "aws_elasticache_replication_group" "chat_redis_cluster" {
  apply_immediately          = var.chat_redis_cluster_apply_immediately
  replication_group_id       = local.chat_redis_name
  description                = "Redis for Sidekiq queues"
  node_type                  = var.chat_redis_cluster_node_type
  num_cache_clusters         = var.chat_redis_cluster_num_cache_clusters
  automatic_failover_enabled = var.chat_redis_cluster_automatic_failover_enabled
  multi_az_enabled           = var.chat_redis_cluster_multi_az_enabled
  parameter_group_name       = var.chat_redis_cluster_parameter_group_name
  engine_version             = var.chat_redis_cluster_engine_version
  subnet_group_name          = aws_elasticache_subnet_group.chat_redis_cluster.name
  security_group_ids         = [aws_security_group.chat_redis_cluster.id]
  tags = {
    Name = local.chat_redis_name
  }
}

resource "aws_route53_record" "chat_redis_cluster" {
  zone_id = local.internal_dns_zone_id
  # TODO: consider removing EKS suffix once the old EC2 environments are gone.
  name    = "${local.chat_redis_name}.eks"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_replication_group.chat_redis_cluster.primary_endpoint_address]
}
