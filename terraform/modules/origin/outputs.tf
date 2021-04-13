output "frontend_target_group_arn" {
  value = aws_lb_target_group.origin-frontend.arn
}

output "security_group_id" {
  value = aws_security_group.origin_alb.id
}

output "fqdn" {
  value = aws_route53_record.origin_cloudfront.fqdn
}

output "cloudfront_access_identity_iam_arn" {
  value = aws_cloudfront_origin_access_identity.cloudfront_s3_access.iam_arn
}
