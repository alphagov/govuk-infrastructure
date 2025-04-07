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
