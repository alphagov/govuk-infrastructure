locals {
  default_max_ecpus_per_second = 5000
  default_max_storage_gb       = 10
  default_engine_version       = "8"
}

resource "aws_security_group" "cache" {
  for_each    = var.instances
  name        = "elasticache-${each.key}"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "EKS to ElastiCache instance ${each.key} (govuk-infrastructure/terraform/deployments/elasticache)"
}

resource "aws_vpc_security_group_ingress_rule" "cache" {
  for_each          = var.instances
  security_group_id = aws_security_group.cache[each.key].id

  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

resource "aws_elasticache_serverless_cache" "cache" {
  for_each             = var.instances
  name                 = each.key
  engine               = "valkey"
  major_engine_version = try(each.value.major_engine_version, local.default_engine_version)
  security_group_ids   = [aws_security_group.cache[each.key].id]
  subnet_ids           = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.private_subnets

  cache_usage_limits {
    data_storage {
      maximum = try(each.value.max_storage_gb, local.default_max_storage_gb)
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = try(each.value.max_ecpus_per_second, local.default_max_ecpus_per_second)
    }
  }
}

resource "aws_secretsmanager_secret" "urls" {
  name = "govuk/elasticache/urls"
}

resource "aws_secretsmanager_secret_version" "urls" {
  secret_id     = "govuk/elasticache/urls"
  secret_string = jsonencode({ for name, cache in aws_elasticache_serverless_cache.cache : name => "rediss://${cache.endpoint[0].address}:${cache.endpoint[0].port}" })
}
