output "opensearch_endpoint" {
  value = aws_opensearch_domain.opensearch.endpoint
}

output "opensearch_domain_arn" {
  value = aws_opensearch_domain.opensearch.arn
}

output "opensearch_domain_name" {
  value = aws_opensearch_domain.opensearch.domain_name
}

output "opensearch_engine_version" {
  value = aws_opensearch_domain.opensearch.engine_version
}

output "vpc_endpoint" {
  value = var.create_vpc_endpoint ? aws_opensearch_vpc_endpoint.opensearch[0].endpoint : null
}
