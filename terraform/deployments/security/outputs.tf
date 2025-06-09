output "govuk_asset-master-efs_access_sg_id" {
  description = "Security Group ID for GOV.UK asset-master EFS Access"
  value       = aws_security_group.govuk_asset-master-efs_access.id
}

output "govuk_content-data-api-postgresql-primary_access_sg_id" {
  description = "Security Group ID for GOV.UK content-data-api Primary Postgres DB Access"
  value       = aws_security_group.govuk_content-data-api-postgresql-primary_access.id
}

output "govuk_elasticsearch6_access_sg_id" {
  description = "Security Group ID for GOV.UK Elasticsearch 6 Access"
  value       = aws_security_group.govuk_elasticsearch6_access.id
}

output "search-ltr-generation_access_sg_id" {
  description = "Security Group ID for GOV.UK Search LTR Generation Access"
  value       = aws_security_group.search-ltr-generation_access.id
}

output "govuk_licensify-documentdb_access_sg_id" {
  description = "Security Group ID for GOV.UK Licensify DocumentDB Access"
  value       = aws_security_group.govuk_licensify-documentdb_access.id
}

output "govuk_shared_documentdb_access_sg_id" {
  description = "Security Group ID for GOV.UK Shared DocumentDB Access"
  value       = aws_security_group.govuk_shared_documentdb_access.id
}