output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate data required to communicate with the cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "worker_iam_role_arn" {
  description = "IAM role ARN for EKS worker node groups"
  value       = module.eks.worker_iam_role_arn
}

output "cluster_id" {
  description = "The name (also known as the ID) of the EKS cluster."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's kube-apiserver."
  value       = module.eks.cluster_endpoint
}
