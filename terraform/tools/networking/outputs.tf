output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "Id of the VPC created for this environment"
}

output "public_subnet_ids" {
  value       = [for subnet in aws_subnet.public : subnet.id]
  description = "Ids of each public subnet"
}

output "private_subnet_ids" {
  value       = [for subnet in aws_subnet.private : subnet.id]
  description = "Ids of each private subnet"
}

output "eks_control_plane_subnet_ids" {
  value       = [for subnet in aws_subnet.eks_control_plane : subnet.id]
  description = "Ids of each EKS control plane subnet"
}
