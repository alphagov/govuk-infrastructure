output "opensearch_domain_names" {
  description = "A map of the OpenSearch domain names for the blue and green clusters, clusters which haven't be launched will be null"
  value = {
    blue  = var.launch_blue_domain ? local.blue_domain_name : null
    green = var.launch_green_domain ? local.green_domain_name : null
  }
}

output "opensearch_domain_arns" {
  description = "A map of the AWS OpenSearch domain ARNS for the blue and green clusters,  clusters which haven't be launched will be null"
  value = {
    blue  = var.launch_blue_domain ? module.blue_domain[0].opensearch_domain_arn : null
    green = var.launch_green_domain ? module.green_domain[0].opensearch_domain_arn : null
  }
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

output "green_elasticsearch_endpoint" {
  description = "The endpoint of the green elasticsearch domain"
  deprecated  = "Do not set this option except when importing the existing Search ElasticSearch cluster"
  value       = var.launch_green_domain && var.use_aws_elasticsearch_domain_resource_for_green_cluster ? module.green_domain[0].opensearch_endpoint : null
}

output "elasticsearch_iam_role_arn" {
  description = "The endpoint of the green elasticsearch domain"
  deprecated  = "Do not set this option except when importing the existing Search ElasticSearch cluster"
  value       = var.create_additional_manual_snapshot_role_name == null ? null : aws_iam_role.elasticsearch_snapshot[0].arn
}
