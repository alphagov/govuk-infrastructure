output "logging_bucket" {
  description = "Centralised AWS S3 bucket for logging"
  value       = module.logging_bucket
}

output "state_files_bucket" {
  description = "Centralised terraform state files bucket for all accounts"
  value       = module.state_file_bucket
}

output "tools_govuk_digital_zone_id" {
  description = "Route53 hosted zone ID for tools.govuk.digital"
  value       = aws_route53_zone.tools_govuk_digital.zone_id
}

output "tools_govuk_digital_name_servers" {
  description = "Nameservers for tools.govuk.digital"
  value       = aws_route53_zone.tools_govuk_digital.name_servers
}

output "tools_govuk_digital_certificate_arn" {
  description = "ARN of the ACM certificate for tools.govuk.digital and *.tools.govuk.digital"
  value       = aws_acm_certificate.tools_govuk_digital.arn
}
