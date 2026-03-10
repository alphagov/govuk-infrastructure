ebs = {
  volume_size      = 171
  volume_type      = "gp3"
  throughput       = 250
  provisioned_iops = 3000
}

engine_version         = "6.7"
zone_awareness_enabled = true
elasticsearch_enabled  = false

instance_count = 3
instance_type  = "r5.4xlarge.elasticsearch"

dedicated_master = {
  instance_count = 3
  instance_type  = "c5.xlarge.elasticsearch"
}

tls_security_policy = "Policy-Min-TLS-1-0-2019-07"

stackname = "blue"

elasticsearch6_manual_snapshot_bucket_arns = [
  "arn:aws:s3:::govuk-production-elasticsearch6-manual-snapshots",
]

encryption_at_rest = true
