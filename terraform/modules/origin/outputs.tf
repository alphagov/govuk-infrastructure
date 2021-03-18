output "frontend_target_group_arn" {
  value = aws_lb_target_group.origin-frontend.arn
}

output "security_group_id" {
  value = aws_security_group.origin_alb.id
}

output "fqdn" {
  value = "${aws_route53_record.origin_alb.name}.${var.publishing_service_domain}"
}

output "origin_app_fqdn" {
  value = aws_route53_record.origin_alb.fqdn
}

output "cloudfront_access_identity_iam_arn" {
  value = aws_cloudfront_origin_access_identity.cloudfront_s3_access.iam_arn
}

output "cloudfront_security_groups_updater_lambda_name" {
  value = aws_lambda_function.cloudfront_security_groups_updater.function_name
}
