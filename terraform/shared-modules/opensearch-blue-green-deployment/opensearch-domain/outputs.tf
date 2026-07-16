output "opensearch_endpoint" {
  value = var.use_aws_elasticsearch_domain_resource ? aws_elasticsearch_domain.elasticsearch[0].endpoint : aws_opensearch_domain.opensearch[0].endpoint
}

output "opensearch_domain_arn" {
  value = var.use_aws_elasticsearch_domain_resource ? aws_elasticsearch_domain.elasticsearch[0].arn : aws_opensearch_domain.opensearch[0].arn
}

output "opensearch_domain_name" {
  value = var.use_aws_elasticsearch_domain_resource ? aws_elasticsearch_domain.elasticsearch[0].domain_name : aws_opensearch_domain.opensearch[0].domain_name
}

output "opensearch_engine_version" {
  value = var.use_aws_elasticsearch_domain_resource ? aws_elasticsearch_domain.elasticsearch[0].elasticsearch_version : aws_opensearch_domain.opensearch[0].engine_version
}

output "vpc_endpoint" {
  value = var.create_vpc_endpoint ? (
    var.use_aws_elasticsearch_domain_resource
    ? aws_elasticsearch_vpc_endpoint.elasticsearch[0].endpoint
    : aws_opensearch_vpc_endpoint.opensearch[0].endpoint
  ) : null
}
