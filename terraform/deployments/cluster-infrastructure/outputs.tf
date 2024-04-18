output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate data required to communicate with the cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "worker_iam_role_arn" {
  description = "IAM role ARN for EKS worker node groups"
  value       = aws_iam_role.node.arn
}

output "worker_iam_role_name" {
  description = "IAM role name for EKS worker node groups"
  value       = aws_iam_role.node.name
}

output "aws_ebs_csi_driver_iam_role_arn" {
  description = "IAM role ARN for AWS EBS CSI controller role"
  value       = module.aws_ebs_csi_driver_iam_role.iam_role_arn
}

output "control_plane_security_group_id" {
  description = "ID of the security group which contains the (AWS-owned) control plane nodes."
  value       = module.eks.cluster_primary_security_group_id
}

output "node_security_group_id" {
  description = "ID of the security group which contains the worker nodes. May or may not be the same as control_plane_security_group_id."
  value       = module.eks.cluster_primary_security_group_id
}

output "cluster_autoscaler_service_account_name" {
  description = "Name of the k8s service account for the cluster autoscaler."
  value       = local.cluster_autoscaler_service_account_name
}

output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN corresponding to the k8s service account for the AWS Load Balancer Controller."
  value       = module.cluster_autoscaler_iam_role.iam_role_arn
}

output "cluster_id" {
  description = "The name (also known as the ID) of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's kube-apiserver."
  value       = module.eks.cluster_endpoint
}

output "cluster_oidc_provider" {
  description = "The OpenID Connect provider for the EKS cluster (without https://)"
  value       = module.eks.oidc_provider
}

output "cluster_oidc_provider_arn" {
  description = "The ARN of the OpenID Connect provider for the EKS cluster."
  value       = module.eks.oidc_provider_arn
}

output "cluster_services_namespace" {
  description = "The namespace for cluster services."
  value       = local.cluster_services_namespace
}

output "external_dns_service_account_name" {
  description = "Name of the k8s service account for the external-dns addon."
  value       = local.external_dns_service_account_name
}

output "external_dns_role_arn" {
  description = "IAM role ARN corresponding to the k8s service account for the external-dns addon."
  value       = module.external_dns_iam_role.iam_role_arn
}

output "external_dns_zone_id" {
  description = "Hosted Zone ID of the Route53 zone to be managed by the external-dns addon."
  value       = aws_route53_zone.cluster_public.zone_id
}

output "external_dns_zone_name" {
  description = "Domain name of the Route53 zone to be managed by the external-dns addon."
  value       = local.external_dns_zone_name
}

output "external_secrets_service_account_name" {
  description = "Name of the k8s service account for external-secrets."
  value       = local.external_secrets_service_account_name
}

output "external_secrets_role_arn" {
  description = "IAM role ARN corresponding to the k8s service account for external-secrets."
  value       = module.external_secrets_iam_role.iam_role_arn
}

output "aws_lb_controller_role_arn" {
  description = "IAM role ARN corresponding to the k8s service account for the AWS Load Balancer Controller."
  value       = module.aws_lb_controller_iam_role.iam_role_arn
}

output "aws_lb_controller_service_account_name" {
  description = "Name of the k8s service account for the AWS Load Balancer Controller."
  value       = local.aws_lb_controller_service_account_name
}

output "aws_ebs_csi_driver_controller_service_account_name" {
  description = "Name of the k8s service account for the AWS EBS CSI Controller"
  value       = local.ebs_csi_driver_controller_service_account_name
}

output "grafana_iam_role_arn" {
  description = "IAM role ARN corresponding to the k8s service account for Grafana."
  value       = module.grafana_iam_role.iam_role_arn
}

output "monitoring_namespace" {
  description = "The namespace for monitoring."
  value       = local.monitoring_namespace
}

output "clamav_db_efs_id" {
  value = aws_efs_file_system.clamav-db.id
}

output "public_nat_gateway_ips" {
  value = [for eip in aws_eip.eks_nat : eip.public_ip]
}

output "private_subnets" {
  value = [for sn in aws_subnet.eks_private : sn.id]
}

output "public_subnets" {
  value = [for sn in aws_subnet.eks_public : sn.id]
}

output "control_plane_subnets" {
  value = [for sn in aws_subnet.eks_control_plane : sn.id]
}
