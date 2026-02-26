output "sg_neptune" {
  description = "Neptune instance security groups"
  value       = { for k, v in aws_security_group.this : k => v.id }
}

output "nepture_instance_id" {
  description = "Neptune instance IDs"
  value       = { for k, v in aws_neptune_cluster.this : k => v.id }
}

output "neptune_cluster_id" {
  description = "Neptune cluster IDs"
  value       = { for k, v in aws_neptune_cluster.this : k => v.id }
}

output "neptune_cluster_resource_id" {
  description = "Neptune cluster resource IDs"
  value       = { for k, v in aws_neptune_cluster.this : k => v.cluster_resource_id }
}

output "neptune_cluster_arn" {
  description = "Neptune cluster arns"
  value       = { for k, v in aws_neptune_cluster.this : k => v.arn }
}

output "neptune_reader_endpoint" {
  description = "Neptune instance endpoints"
  value       = { for k, v in aws_neptune_cluster.this : k => v.reader_endpoint }
}

output "neptune_cluster_hosted_zone_id" {
  description = "Neptune cluster hosted zone id"
  value       = { for k, v in aws_neptune_cluster.this : k => v.hosted_zone_id }
}

