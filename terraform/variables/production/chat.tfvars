chat_redis_cluster_apply_immediately          = false
chat_redis_cluster_automatic_failover_enabled = true
chat_redis_cluster_multi_az_enabled           = true
chat_redis_cluster_node_type                  = "cache.r6g.xlarge"
chat_redis_cluster_num_cache_clusters         = "2"
chat_token_limits_per_minute = {
  "claude_sonnet"     = 9000000, # Sonnet 4
  "claude_sonnet_4_5" = 6000000,
  "haiku_4_5"         = 6000000,
  "openai_gpt_oss"    = 100000000,
  "titan_embed"       = 1200000
}
