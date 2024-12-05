output "eks_ingress_www_origin_security_group_name" {
  value = aws_security_group.eks_ingress_www_origin.name
}

output "assets_efs_id" {
  description = "EFS Filesystem ID for assets"
  value       = aws_efs_file_system.assets_efs.id
}