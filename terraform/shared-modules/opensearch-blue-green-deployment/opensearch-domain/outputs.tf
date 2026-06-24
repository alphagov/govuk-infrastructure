output "opensearch_endpoint" {
  value = var.use_aws_elasticsearch_domain_resource ? aws_elasticsearch_domain.elasticsearch[0].endpoint : aws_opensearch_domain.opensearch[0].endpoint
}

output "opensearch_domain_arn" {
  value = var.use_aws_elasticsearch_domain_resource ? aws_elasticsearch_domain.elasticsearch[0].arn : aws_opensearch_domain.opensearch[0].arn
}
