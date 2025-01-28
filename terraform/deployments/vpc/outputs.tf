output "id" { value = aws_vpc.vpc.id }

output "aws_logging_bucket_id" {
  value       = aws_s3_bucket.aws_logging.id
  description = "Name of the AWS logging bucket"
}

output "aws_logging_bucket_arn" {
  value       = aws_s3_bucket.aws_logging.arn
  description = "ARN of the AWS logging bucket"
}

output "rds_enhanced_monitoring_role_arn" {
  description = "The ARN of the IAM role for RDS Enhanced Monitoring"
  value       = aws_iam_role.rds_enhanced_monitoring.arn
}

output "internal_root_zone_id" {
  description = "ID of the internal Route53 DNS zone"
  value       = aws_route53_zone.internal_zone.id
}

output "internal_root_zone_name" {
  description = "Name of the internal Route53 DNS zone"
  value       = aws_route53_zone.internal_zone.name
}

output "external_root_zone_id" {
  description = "ID of the external Route53 DNS zone"
  value       = aws_route53_zone.external_zone.id
}

output "external_root_zone_name" {
  description = "Name of the external Route53 DNS zone"
  value       = aws_route53_zone.external_zone.name
}

output "private_subnet_ids" {
  description = "A map of private subnet names to IDs"
  value       = { for name, subnet in var.legacy_private_subnets : name => aws_subnet.private_subnet[name].id }
}

output "public_subnet_ids" {
  description = "A map of public subnet names to IDs"
  value       = { for name, subnet in var.legacy_public_subnets : name => aws_subnet.public_subnet[name].id }
}

output "internet_gateway_id" {
  value = aws_internet_gateway.public.id
}
