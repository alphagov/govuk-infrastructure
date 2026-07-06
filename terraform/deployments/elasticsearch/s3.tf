// This is now managed in ../elasticsearch-green as part of module.opensearch
removed {
  from = module.secure_s3_bucket_manual_snapshots
  lifecycle {
    destroy = false
  }
}
