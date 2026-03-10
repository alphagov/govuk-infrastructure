ebs = {
  volume_size      = 85
  volume_type      = "gp3"
  throughput       = 125
  provisioned_iops = 3000
}

govuk_environment      = "staging"
engine_version         = "6.7"
zone_awareness_enabled = true
elasticsearch_enabled  = false

instance_count = 3
instance_type  = "r5.2xlarge.elasticsearch"

dedicated_master = {
  instance_count = 3
  instance_type  = "c5.large.elasticsearch"
}

tls_security_policy = "Policy-Min-TLS-1-0-2019-07"

stackname = "blue"

elasticsearch6_manual_snapshot_bucket_arns = [
  "arn:aws:s3:::govuk-production-elasticsearch6-manual-snapshots",
  "arn:aws:s3:::govuk-staging-elasticsearch6-manual-snapshots"
]

encryption_at_rest = true
