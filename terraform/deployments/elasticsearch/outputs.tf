output "service_endpoint" {
  value       = aws_elasticsearch_domain.opensearch.endpoint
  description = "Endpoint to submit index, search, and upload requests"
}

output "service_dns_name" {
  value       = aws_route53_record.service_record.fqdn
  description = "DNS name to access the Elasticsearch internal service"
}

output "domain_configuration_policy_arn" {
  value       = aws_iam_policy.can_configure_es_snapshots.arn
  description = "ARN of the policy used to configure the elasticsearch domain"
}

output "manual_snapshots_bucket_arn" {
  value       = aws_s3_bucket.manual_snapshots.arn
  description = "ARN of the bucket to store manual snapshots"
}
