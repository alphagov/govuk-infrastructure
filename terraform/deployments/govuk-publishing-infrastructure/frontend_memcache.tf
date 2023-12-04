locals {
  frontend_memcached_name = "frontend-memcached-${local.cluster_name}"
}

resource "aws_elasticache_subnet_group" "frontend_memcached" {
  name       = "frontend-memcached"
  subnet_ids = local.elasticache_subnets
}

resource "aws_security_group" "frontend_memcached" {
  name        = local.frontend_memcached_name
  vpc_id      = local.vpc_id
  description = "${local.frontend_memcached_name} memcached instance"
  tags = {
    Product     = "GOV.UK"
    System      = "Frontend Memcached"
    Environment = "${var.govuk_environment}"
    Owner       = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
    Name        = local.frontend_memcached_name
  }
}

resource "aws_elasticache_cluster" "frontend_memcached" {
  cluster_id = "frontend-memcached-${local.cluster_name}"

  engine          = "memcached"
  engine_version  = "1.6.6"
  node_type       = var.frontend_memcached_node_type
  num_cache_nodes = 1 # TODO: consider whether failover is needed

  apply_immediately    = var.govuk_environment != "production"
  parameter_group_name = "default.memcached1.6"
  subnet_group_name    = aws_elasticache_subnet_group.frontend_memcached.name
  security_group_ids   = [aws_security_group.frontend_memcached.id]
  tags = {
    Product     = "GOV.UK"
    System      = "Frontend Memcached"
    Environment = "${var.govuk_environment}"
    Owner       = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
    Name        = local.frontend_memcached_name
  }
}

resource "aws_route53_record" "frontend_memcached" {
  zone_id = local.internal_dns_zone_id
  # TODO: consider removing EKS suffix once the old EC2 environments are gone.
  name    = "frontend-memcached-${local.cluster_name}.eks"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_cluster.frontend_memcached.cluster_address]
}
