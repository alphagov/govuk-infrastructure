resource "aws_elasticache_subnet_group" "cache" {
  name       = "govuk-elasticaches"
  subnet_ids = local.elasticache_subnets
  tags = {
    "Name" = "govuk-elasticaches-subnet-group"
  }
}

resource "aws_elasticache_parameter_group" "cache" {
  for_each = var.caches

  name   = each.value.name
  family = each.value.family

  dynamic "parameter" {
    for_each = each.value.parameters

    content {
      name  = parameter.key
      value = parameter.value
    }
  }
  tags = {
    "Name" = each.value.name
  }
}

resource "aws_elasticache_replication_group" "cache" {
  for_each = var.caches

  replication_group_id       = each.value.name
  description                = each.value.description
  num_cache_clusters         = each.value.num_cache_clusters
  node_type                  = each.value.node_type
  automatic_failover_enabled = each.value.automatic_failover_enabled
  multi_az_enabled           = each.value.multi_az_enabled
  engine                     = each.value.engine
  engine_version             = each.value.engine_version
  parameter_group_name       = aws_elasticache_parameter_group.cache[each.key].name
  subnet_group_name          = aws_elasticache_subnet_group.cache.name
  security_group_ids         = [aws_security_group.cache.id]
  tags = {
    "Name" = each.value.name
  }
}
