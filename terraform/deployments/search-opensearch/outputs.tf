output "service_dns_name" {
  value       = module.opensearch.opensearch_cname
  description = "DNS name to access the Elasticsearch internal service"
}

output "opensearch_domain_arns" {
  value       = module.opensearch.opensearch_domain_arns
  description = "The ARNs for the blue and/or green clusters"
}

output "live_opensearch_url" {
  value       = module.opensearch.opensearch_cname
  description = "The FQDN of the CNAME that points to the live OpenSearch domain"
}

output "opensearch_endpoints" {
  description = "The domain endpoints for the blue and/or green clusters directly (do not use this in production, use live_opensearch_url instead"
  value       = module.opensearch.opensearch_domain_endpoints
}

output "domain_configuration_policy_arn" {
  value       = aws_iam_policy.can_configure_es_snapshots.arn
  description = "ARN of the policy used to configure the elasticsearch domain"
}

output "snapshot_role_name" {
  value       = module.opensearch.opensearch_iam_role_name
  description = "The name of the IAM role the cluster can use for performing, and restoring, snapshots"
}

output "snapshot_role_arn" {
  value       = module.opensearch.opensearch_iam_role_arn
  description = "The ARN of the IAM role the cluster can use for performing, and restoring, snapshots"
}

output "snapshot_bucket_arn" {
  value       = module.opensearch.s3_snapshot_bucket_arn
  description = "The ARN of the S3 bucket for writing snapshots to"
}

output "snapshot_bucket_name" {
  value       = module.opensearch.s3_snapshot_bucket_name
  description = "The name of the S3 bucket for writing snapshots to"
}

output "secrets_manager_secret_name" {
  value       = module.opensearch.secrets_manager_secret_name
  description = "The name of the AWS Secrets Manager Secret which holds the URL, and if advanced security is enabled the master username & password"
}

output "vpc_endpoints" {
  value       = module.opensearch.vpc_endpoints
  description = "The VPC endpoints of blue and green clusters, or null if they have not been created"
}
