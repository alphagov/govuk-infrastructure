output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate data required to communicate with the cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "worker_iam_role_arn" {
  description = "IAM role ARN for EKS worker node groups"
  value       = module.eks.worker_iam_role_arn
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
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's kube-apiserver."
  value       = module.eks.cluster_endpoint
}

output "cluster_services_namespace" {
  description = "The namespace for cluster services."
  value       = local.cluster_services_namespace
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
