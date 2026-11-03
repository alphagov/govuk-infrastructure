output "id" { value = aws_vpc.vpc.id }

output "private_subnet_route_table_ids" {
  value = [for rt in aws_route_table.private_subnet : rt.id]
}

output "internet_gateway_id" {
  value = aws_internet_gateway.public.id
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

output "external_dns_service_account_name" {
  description = "Name of the k8s service account for the external-dns addon."
  value       = local.external_dns_service_account_name
}

output "external_dns_role_arn" {
  description = "IAM role ARN corresponding to the k8s service account for the external-dns addon."
  value       = module.external_dns_iam_role.arn
}

output "external_dns_zone_id" {
  description = "Hosted Zone ID of the Route53 zone to be managed by the external-dns addon."
  value       = aws_route53_zone.cluster_public.zone_id
}

output "external_dns_zone_name" {
  description = "Domain name of the Route53 zone to be managed by the external-dns addon."
  value       = local.external_dns_zone_name
}

