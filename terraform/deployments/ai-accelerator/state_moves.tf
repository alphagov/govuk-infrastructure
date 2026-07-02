moved {
  from = module.opensearch.module.snapshot_bucket
  to   = module.opensearch.module.snapshot_bucket[0]
}
