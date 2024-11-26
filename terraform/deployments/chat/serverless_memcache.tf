locals {
  chat_memcached_name = "chat-memcached"
}

resource "aws_security_group" "chat_memcached" {
  name        = local.chat_memcached_name
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "${local.chat_memcached_name} memcached instance"
  tags = {
    Name = local.chat_memcached_name
  }
}

resource "aws_elasticache_serverless_cache" "chat_memcached" {
  name                 = local.chat_memcached_name
  engine               = "memcached"
  major_engine_version = "1.6"
  cache_usage_limits {
    data_storage {
      maximum = 10
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 4000
    }
  }
  subnet_ids         = local.elasticache_subnets
  security_group_ids = [aws_security_group.chat_memcached.id]
  tags = {
    Name = local.chat_memcached_name
  }
}
