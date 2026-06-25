output "service_dns_name" {
  value       = module.opensearch.opensearch_cname
  description = "DNS name to access the Elasticsearch internal service"
}

output "domain_configuration_policy_arn" {
  value       = aws_iam_policy.can_configure_es_snapshots.arn
  description = "ARN of the policy used to configure the elasticsearch domain"
}
