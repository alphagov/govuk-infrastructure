locals {
  default_max_ecpus_per_second = 5000
  default_max_storage_gb       = 10
  default_engine_version       = "8"
}

resource "aws_security_group" "cache" {
  name        = "elasticache-shared"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "EKS to shared ElastiCache instance (govuk-infrastructure/terraform/deployments/elasticache)"
}

resource "aws_vpc_security_group_ingress_rule" "cache" {
  security_group_id = aws_security_group.cache.id

  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

resource "aws_elasticache_subnet_group" "cache" {
  name       = "elasticache-shared"
  subnet_ids = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.private_subnets
}

resource "aws_elasticache_parameter_group" "cache" {
  name   = "elasticache-shared"
  family = "valkey8"

  parameter {
    name  = "databases"
    value = 10000
  }

  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }
}

resource "aws_elasticache_replication_group" "cache" {
  replication_group_id = "govuk-shared"
  description          = "Shared Valkey"
  num_cache_clusters   = 1
  node_type            = var.node_type
  engine               = "valkey"
  engine_version       = var.engine_version
  parameter_group_name = aws_elasticache_parameter_group.cache.name
  subnet_group_name    = aws_elasticache_subnet_group.cache.name
  security_group_ids   = [aws_security_group.cache.id]
}

resource "aws_secretsmanager_secret" "urls" {
  name = "govuk/elasticache/urls"
}

resource "aws_secretsmanager_secret_version" "urls" {
  secret_id     = "govuk/elasticache/urls"
  secret_string = jsonencode({ for app, dbId in var.databases : app => "redis://${aws_elasticache_replication_group.cache.primary_endpoint_address}:6379/${dbId}" })
}
