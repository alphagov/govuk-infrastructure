output "opensearch_domain_names" {
  description = "A map of the OpenSearch domain names for the blue and green clusters, clusters which haven't be launched will be null"
  value = merge({
    blue  = var.launch_blue_domain ? "${var.opensearch_domain_name}-blue" : null
    green = var.launch_green_domain ? "${var.opensearch_domain_name}-green" : null
  })
}

output "opensearch_cname" {
  description = "The fully qualified domain name of the route53 record which points to the live OpenSearch domain"
  value       = aws_route53_record.service_record.fqdn
}

output "s3_snapshot_bucket_name" {
  description = "Name of the S3 bucket used for snapshots"
  value       = module.snapshot_bucket.name
}

output "s3_snapshot_bucket_arn" {
  description = "ARN of the S3 bucket used for snapshots"
  value       = module.snapshot_bucket.arn
}

output "opensearch_iam_role_name" {
  description = "The name of the IAM role used for OpenSearch to read and write Snapshots"
  value       = aws_iam_role.opensearch_snapshot.name
}

output "opensearch_iam_role_arn" {
  description = "The ARN of the IAM role used for OpenSearch to read and write Snapshots"
  value       = aws_iam_role.opensearch_snapshot.arn
}

output "secrets_manager_secret_name" {                                                                     # pragma: allowlist secret
  description = "The name of the Secrets Manager secret which contains the OpenSearch master user details" # pragma: allowlist secret
  value       = aws_secretsmanager_secret.opensearch_passwords.name                                        # pragma: allowlist secret
}
