chat_redis_cluster_apply_immediately          = true
chat_redis_cluster_automatic_failover_enabled = false
chat_redis_cluster_multi_az_enabled           = false
chat_redis_cluster_node_type                  = "cache.r6g.xlarge"
chat_redis_cluster_num_cache_clusters         = "1"
chat_token_limits_per_minute = {
  "claude_sonnet"      = 200000,
  "openai_gpt_oss"     = 100000000,
  "titan_embed_dublin" = 300000
  "titan_embed_london" = 300000
}
