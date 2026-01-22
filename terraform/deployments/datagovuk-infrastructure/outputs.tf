# WAF Outputs for reference and debugging
output "find_waf_arn" {
  description = "ARN of the Find WAF Web ACL"
  value       = aws_wafv2_web_acl.find.arn
}
output "find_waf_id" {
  description = "ID of the Find WAF Web ACL"
  value       = aws_wafv2_web_acl.find.id
}
output "find_alb_arn" {
  description = "ARN of the Find ALB"
  value       = data.aws_lb.find.arn
}
output "find_cloudwatch_log_group" {
  description = "CloudWatch Log Group for WAF logs"
  value       = aws_cloudwatch_log_group.find_waf.name
}
output "find_waf_rate_limits" {
  description = "Current rate limit configuration for Find WAF"
  value = {
    environment = var.govuk_environment
    warning     = local.waf_rate_limits.warning
    block       = local.waf_rate_limits.block
  }
}
output "ckan_waf_arn" {
  description = "ARN of the CKAN WAF Web ACL"
  value       = aws_wafv2_web_acl.ckan.arn
}
output "ckan_waf_id" {
  description = "ID of the CKAN WAF Web ACL"
  value       = aws_wafv2_web_acl.ckan.id
}
output "ckan_alb_arn" {
  description = "ARN of the CKAN ALB"
  value       = data.aws_lb.ckan.arn
}
output "ckan_cloudwatch_log_group" {
  description = "CloudWatch CKAN Log Group for WAF logs"
  value       = aws_cloudwatch_log_group.ckan_waf.name
}
output "ckan_waf_rate_limits" {
  description = "Current rate limit configuration for CKAN WAF"
  value = {
    environment = var.govuk_environment
    warning     = local.ckan_rate_limits.warning
    block       = local.ckan_rate_limits.block
  }
}
