locals {
  shared_redis_name = "shared-redis-${local.cluster_name}"
}

resource "aws_elasticache_subnet_group" "shared_redis_cluster" {
  name       = local.shared_redis_name
  subnet_ids = local.elasticache_subnets
}

resource "aws_security_group" "shared_redis_cluster" {
  name        = local.shared_redis_name
  vpc_id      = local.vpc_id
  description = "${local.shared_redis_name} Redis cluster"
  tags = {
    Name        = local.shared_redis_name
    Product     = "GOV.UK"
    System      = "Shared Redis"
    Service     = "Shared Redis Security Group"
    Environment = "${var.govuk_environment}"
    Owner       = "govuk-replatforming-team@digital.cabinet-office.gov.uk"
  }
}

resource "aws_elasticache_replication_group" "shared_redis_cluster" {
  apply_immediately          = var.govuk_environment != "production"
  replication_group_id       = local.shared_redis_name
  description                = "${local.shared_redis_name} Redis cluster with Redis master and replica"
  node_type                  = var.shared_redis_cluster_node_type
  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled           = true
  parameter_group_name       = "default.redis6.x"
  engine_version             = "6.x"
  subnet_group_name          = aws_elasticache_subnet_group.shared_redis_cluster.name
  security_group_ids         = [aws_security_group.shared_redis_cluster.id]
  tags = {
    Name        = local.shared_redis_name
    Product     = "GOV.UK"
    System      = "Shared Redis"
    Service     = "Shared Redis Security Group"
    Environment = "${var.govuk_environment}"
    Owner       = "govuk-replatforming-team@digital.cabinet-office.gov.uk"
  }
}

resource "aws_route53_record" "shared_redis_cluster" {
  zone_id = local.internal_dns_zone_id
  # TODO: consider removing EKS suffix once the old EC2 environments are gone.
  name    = "${local.shared_redis_name}.eks"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_replication_group.shared_redis_cluster.primary_endpoint_address]
}
