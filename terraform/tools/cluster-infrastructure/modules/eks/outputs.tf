output "cluster_name" {
  value       = aws_eks_cluster.this.name
  description = "The name of the cluster"
}

output "cluster_arn" {
  value       = aws_eks_cluster.this.arn
  description = "The arn of the cluster"
}


output "oidc_provider" {
  value       = aws_eks_cluster.this.identity.oidc.issuer
  description = "The oidc issuer for the cluster"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.this.endpoint
  description = "The cluster endpoint of the cluster"
}

output "ca_base64" {
  value       = aws_eks_cluster.this.certificate_authority.data
  description = "The base64 encoded ca for the cluster"

}
