output "cluster_name" {
  value       = module.eks.cluster_name
  description = "The name of the cluster"
}

output "cluster_arn" {
  value       = module.eks.cluster_arn
  description = "The arn of the cluster"
}


output "oidc_provider" {
  value       = module.eks.oidc_provider
  description = "The oidc issuer for the cluster"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "The cluster endpoint of the cluster"
}

output "cluster_ca_base64" {
  value       = module.eks.ca_base64
  description = "The base64 encoded ca for the cluster"

}

