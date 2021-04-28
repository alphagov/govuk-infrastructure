output "origin_alb_listerner_arn" {
  value = aws_lb_listener.origin.arn
}

output "origin_alb_x_custom_header_secret" {
  value = random_password.origin_alb_x_custom_header_secret.result
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
