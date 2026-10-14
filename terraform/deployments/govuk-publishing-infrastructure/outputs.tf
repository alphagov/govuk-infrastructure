output "eks_ingress_www_origin_security_group_name" {
  value = aws_security_group.eks_ingress_www_origin.name
}
# All SGs to attach to www-origin ALBs (alb.ingress.kubernetes.io/security-groups).
output "eks_ingress_www_origin_security_group_names" {
  value = [
    aws_security_group.eks_ingress_www_origin.name,
    aws_security_group.eks_ingress_www_origin_from_cloudfront.name,
    aws_security_group.eks_ingress_www_origin_from_fastly.name,
    aws_security_group.eks_ingress_www_origin_from_office.name,
  ]
}
