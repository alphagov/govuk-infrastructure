output "eks_ingress_www_origin_security_group_name" {
  value = aws_security_group.eks_ingress_www_origin.name
}

# All SGs to attach to CDN origin ALBs (alb.ingress.kubernetes.io/security-groups).
output "origin_alb_security_group_names" {
  value = [
    aws_security_group.eks_ingress_www_origin.name,
    aws_security_group.origin_alb_from_cloudfront.name,
    aws_security_group.origin_alb_from_fastly.name,
    aws_security_group.origin_alb_from_office.name,
  ]
}
